require "ipaddr"

class AccessRecordService < ApplicationService
  FORWARDED_FOR_HEADER = "X-Forwarded-For".freeze

  def initialize(shorturl_id:, request:)
    @shorturl_id = shorturl_id
    @request = request
  end

  def call
    ShorturlAccess.create!(
      shorturl_id: @shorturl_id,
      ip: ip_address,
      referer: @request.referer,
      timestamp: Time.current,
      geolocation: geolocation
    )
  rescue ActiveRecord::ActiveRecordError => e
    Rails.logger.warn("Fail to save access record: #{e.class}: #{e.message}")
    nil
  end

  private

  def geolocation
    location = Geocoder.search(ip_address).first
    return "Unknown" unless location

    [
      location.city,
      location.state_code.presence || location.state,
      location.country
    ].compact_blank.join(", ").presence || location.address.presence || "Unknown"
  rescue StandardError => e
    Rails.logger.warn("Fail to look up geolocation: #{e.class}: #{e.message}")
    "Unknown"
  end

  def ip_address
    forwarded_ip_address.presence || @request.remote_ip.presence || @request.ip
  end

  def forwarded_ip_address
    return unless @request.respond_to?(:headers)

    @request.headers[FORWARDED_FOR_HEADER].to_s.split(",").map(&:strip).find do |candidate|
      valid_ip_address?(candidate)
    end
  end

  def valid_ip_address?(value)
    IPAddr.new(value)
    true
  rescue IPAddr::InvalidAddressError
    false
  end
end
