require "test_helper"

class AccessRecordServiceTest < ActiveSupport::TestCase
  Request = Data.define(:remote_ip, :ip, :referer)

   setup do
    Geocoder.configure(lookup: :test, ip_lookup: :test, cache: nil)
    Geocoder::Lookup::Test.reset
  end

  teardown do
    Geocoder::Lookup::Test.reset
  end

  test "records access with geocoded location" do
    shorturl = shorturls(:one)
    request = Request.new("203.0.113.10", "203.0.113.10", "https://example.com/source")

    with_geocoder_search(
      "203.0.113.10",
      [
        {
          "city" => "Kuala Lumpur",
          "state_code" => "KUL",
          "state" => nil,
          "country" => "Malaysia",
          "address" => "Kuala Lumpur, Malaysia"
        }
      ]) do
      access = nil
      assert_difference -> { ShorturlAccess.count }, 1 do
        access = AccessRecordService.call(shorturl: shorturl, request: request)
      end

      assert_equal shorturl, access.shorturl
      assert_equal "203.0.113.10", access.ip
      assert_equal "https://example.com/source", access.referer
      assert_equal "Kuala Lumpur, KUL, Malaysia", access.geolocation
      assert access.timestamp.present?
    end
  end

  test "falls back to unknown when geocoder has no result" do
    shorturl = shorturls(:one)
    request = Request.new("198.51.100.25", "198.51.100.25", nil)

    with_geocoder_search("198.51.100.25", []) do
      access = AccessRecordService.call(shorturl: shorturl, request: request)

      assert_equal "Unknown", access.geolocation
    end
  end

  test "falls back to unknown when geocoder lookup fails" do
    shorturl = shorturls(:one)
    request = Request.new("203.0.113.10", "203.0.113.10", nil)

    with_geocoder_error(Timeout::Error) do
      access = AccessRecordService.call(shorturl: shorturl, request: request)

      assert_equal "Unknown", access.geolocation
    end
  end

  test "returns nil when access record cannot be persisted" do
    request = Request.new("203.0.113.10", "203.0.113.10", nil)

    with_geocoder_search("203.0.113.10", []) do
      assert_no_difference -> { ShorturlAccess.count } do
        assert_nil AccessRecordService.call(shorturl: Shorturl.new, request: request)
      end
    end
  end

  private

  def with_geocoder_search(ip_address, results)
    Geocoder::Lookup::Test.add_stub(ip_address, results)
    yield
  end

  def with_geocoder_error(error_class)
    original_search = Geocoder.method(:search)

    Geocoder.define_singleton_method(:search) do |_ip_address|
      raise error_class
    end
    yield
  ensure
    Geocoder.define_singleton_method(:search) do |*args, **kwargs|
      original_search.call(*args, **kwargs)
    end
  end
end
