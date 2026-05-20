class AccessRecordService < ApplicationService
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
    @request.remote_ip.presence || @request.ip
  end
end
