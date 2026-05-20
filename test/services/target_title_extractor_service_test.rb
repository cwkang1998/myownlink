require "test_helper"

class TargetTitleExtractorServiceTest < ActiveSupport::TestCase
  test "extracts normalized title from html response" do
    response = http_ok_response(
      "<html><head><title> CoinGecko &amp;\n Crypto Prices </title></head></html>"
    )

    with_private_host(false) do
      with_request(->(_uri) { response }) do
        title = TargetTitleExtractorService.call(target_url: "https://example.com")

        assert_equal "CoinGecko & Crypto Prices", title
      end
    end
  end

  test "follows redirects before extracting title" do
    requests = []

    with_private_host(false) do
      with_request(->(uri) {
        requests << uri.to_s
        requests.length == 1 ? http_redirect_response("/landing") : http_ok_response("<title>Landing Page</title>")
      }) do
        title = TargetTitleExtractorService.call(target_url: "https://example.com/start")

        assert_equal "Landing Page", title
      end
    end

    assert_equal [ "https://example.com/start", "https://example.com/landing" ], requests
  end

  test "returns nil for non html responses" do
    response = http_ok_response("{}", content_type: "application/json")

    with_private_host(false) do
      with_request(->(_uri) { response }) do
        assert_nil TargetTitleExtractorService.call(target_url: "https://example.com")
      end
    end
  end

  test "returns nil when title is missing" do
    response = http_ok_response("<html><head></head><body>No title</body></html>")

    with_private_host(false) do
      with_request(->(_uri) { response }) do
        assert_nil TargetTitleExtractorService.call(target_url: "https://example.com")
      end
    end
  end

  test "does not fetch private hosts" do
    with_request(->(_uri) { flunk "private hosts should not be fetched" }) do
      assert_nil TargetTitleExtractorService.call(target_url: "http://127.0.0.1/page")
    end

    with_request(->(_uri) { flunk "private hosts should not be fetched" }) do
      assert_nil TargetTitleExtractorService.call(target_url: "http://localhost:3000")
    end
  end

  test "returns nil when request fails" do
    with_private_host(false) do
      with_request(->(_uri) { raise Net::OpenTimeout }) do
        assert_nil TargetTitleExtractorService.call(target_url: "https://example.com")
      end
    end
  end

  private

  def http_ok_response(body, content_type: "text/html")
    Net::HTTPOK.new("1.1", "200", "OK").tap do |response|
      response["content-type"] = content_type
      response.instance_variable_set(:@body, body)
      response.instance_variable_set(:@read, true)
    end
  end

  def http_redirect_response(location)
    Net::HTTPFound.new("1.1", "302", "Found").tap do |response|
      response["location"] = location
    end
  end

  def with_private_host(result)
    original_private_host = TargetTitleExtractorService.instance_method(:private_host?)

    TargetTitleExtractorService.define_method(:private_host?) do |_host|
      result
    end

    yield
  ensure
    TargetTitleExtractorService.define_method(:private_host?, original_private_host)
  end

  def with_request(replacement)
    original_request = TargetTitleExtractorService.instance_method(:request)

    TargetTitleExtractorService.define_method(:request) do |uri|
      replacement.call(uri)
    end

    yield
  ensure
    TargetTitleExtractorService.define_method(:request, original_request)
  end
end
