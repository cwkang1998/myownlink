require "cgi"
require "ipaddr"
require "net/http"
require "resolv"

class TargetTitleExtractorService < ApplicationService
  MAX_RESPONSE_BYTES = 128 * 1024
  MAX_REDIRECTS = 3
  OPEN_TIMEOUT_SECONDS = 2
  READ_TIMEOUT_SECONDS = 2
  USER_AGENT = "Myownlink title extractor".freeze

  def initialize(target_url:)
    @target_url = target_url
  end

  def call
    uri = parse_uri(@target_url)
    return nil unless valid_http_uri?(uri)
    return nil if private_host?(uri.host)

    extract_title(fetch_body(uri, MAX_REDIRECTS))
  rescue StandardError => e
    Rails.logger.warn("Fail to extract target title: #{e.class}: #{e.message}")
    nil
  end

  private

  def parse_uri(value)
    URI.parse(value.to_s)
  rescue URI::InvalidURIError
    nil
  end

  def valid_http_uri?(uri)
    uri.present? && uri.host.present? && uri.scheme.in?(%w[http https])
  end

  def private_host?(host)
    Resolv.getaddresses(host).any? do |address|
      ip_address = IPAddr.new(address)

      # should not allow localhosts
      ip_address.private? || ip_address.loopback? || ip_address.link_local?
    end
  rescue Resolv::ResolvError, IPAddr::InvalidAddressError
    true
  end

  def fetch_body(uri, redirects_remaining)
    response = request(uri)

    if response.is_a?(Net::HTTPRedirection)
      return nil unless redirects_remaining.positive?

      redirected_uri = redirect_uri(uri, response["location"])
      return nil unless valid_http_uri?(redirected_uri)
      return nil if private_host?(redirected_uri.host)

      return fetch_body(redirected_uri, redirects_remaining - 1)
    end

    return nil unless response.is_a?(Net::HTTPSuccess)
    return nil unless html_response?(response)

    response.body.to_s.byteslice(0, MAX_RESPONSE_BYTES)
  end

  def request(uri)
    Net::HTTP.start(
      uri.host,
      uri.port,
      use_ssl: uri.scheme == "https",
      open_timeout: OPEN_TIMEOUT_SECONDS,
      read_timeout: READ_TIMEOUT_SECONDS
    ) do |http|
      request = Net::HTTP::Get.new(uri)
      request["Accept"] = "text/html,application/xhtml+xml"
      request["User-Agent"] = USER_AGENT

      http.request(request)
    end
  end

  def redirect_uri(uri, location)
    return nil if location.blank?

    URI.join(uri, location)
  rescue URI::InvalidURIError
    nil
  end

  def html_response?(response)
    content_type = response["content-type"].to_s.downcase

    content_type.blank? || content_type.include?("text/html") || content_type.include?("application/xhtml+xml")
  end

  def extract_title(body)
    return nil if body.blank?

    match = body.match(%r{<title\b[^>]*>(.*?)</title>}im)
    return nil unless match

    CGI.unescapeHTML(match[1].gsub(/\s+/, " ").strip).presence
  end
end
