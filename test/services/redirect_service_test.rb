require "test_helper"

class RedirectServiceTest < ActiveSupport::TestCase
  Request = Data.define(:remote_ip, :ip, :referer)

  setup do
    Geocoder.configure(lookup: :test, ip_lookup: :test, cache: nil)
    Geocoder::Lookup::Test.reset
    Geocoder::Lookup::Test.add_stub(
      "203.0.113.10",
      [
        {
          "city" => "Kuala Lumpur",
          "state_code" => "KUL",
          "country" => "Malaysia",
          "address" => "Kuala Lumpur, Malaysia"
        }
      ]
    )
  end

  teardown do
    Geocoder::Lookup::Test.reset
  end

  test "resolves target url and records access" do
    shorturl = shorturls(:one)
    request = Request.new("203.0.113.10", "203.0.113.10", "https://example.com/source")

    result = nil
    assert_difference -> { ShorturlAccess.count }, 1 do
      result = RedirectService.call(request: request, short_url_code: shorturl.short_url_code)
    end

    access = ShorturlAccess.order(:created_at).last

    assert result.success?
    assert_equal shorturl.target_url, result.resolved_target_url
    assert_equal shorturl, access.shorturl
    assert_equal "203.0.113.10", access.ip
    assert_equal "https://example.com/source", access.referer
  end

  test "returns failure for invalid short code without recording access" do
    request = Request.new("203.0.113.10", "203.0.113.10", nil)

    assert_no_difference -> { ShorturlAccess.count } do
      result = RedirectService.call(request: request, short_url_code: "not-valid!")

      assert_not result.success?
      assert_nil result.resolved_target_url
    end
  end

  test "returns failure for missing shorturl without recording access" do
    request = Request.new("203.0.113.10", "203.0.113.10", nil)
    missing_code = Base62.encode(Shorturl.maximum(:id) + 1)

    assert_no_difference -> { ShorturlAccess.count } do
      result = RedirectService.call(request: request, short_url_code: missing_code)

      assert_not result.success?
      assert_nil result.resolved_target_url
    end
  end

  test "returns failure for oversized decoded short code without recording access" do
    request = Request.new("203.0.113.10", "203.0.113.10", nil)
    oversized_code = "z" * Base62::MAX_LENGTH

    assert_no_difference -> { ShorturlAccess.count } do
      result = RedirectService.call(request: request, short_url_code: oversized_code)

      assert_not result.success?
      assert_nil result.resolved_target_url
    end
  end
end
