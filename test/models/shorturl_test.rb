require "test_helper"

class ShorturlTest < ActiveSupport::TestCase
  test "target_url must be a valid http url" do
    shorturl = Shorturl.new(title: "Example", target_url: "not-a-url")

    assert_not shorturl.valid?
    assert_includes shorturl.errors[:target_url], "must be a valid URL"
  end

  test "target_url accepts valid http and https urls" do
    assert Shorturl.new(title: "HTTP", target_url: "http://example.com").valid?
    assert Shorturl.new(title: "HTTPS", target_url: "https://example.com/path").valid?
  end

  test "target_url does not accept other url schemes" do
    assert_not Shorturl.new(title: "WS", target_url: "ws://example.com").valid?
    assert_not Shorturl.new(title: "CUSTOM", target_url: "custom://example.com/path").valid?
  end

  test "target_url must not be this app root short url" do
    shorturl = Shorturl.new(title: "Loop", target_url: "http://localhost/ABC123")

    assert_not shorturl.valid?
    assert_includes shorturl.errors[:target_url], "must not be another shortened URL"
  end

  test "target_url allows similar root path on other domains" do
    shorturl = Shorturl.new(title: "External", target_url: "https://external.test/ABC123")

    assert shorturl.valid?
  end

  test "short_url_code is nil before persistence" do
    shorturl = Shorturl.new(title: "Example", target_url: "https://example.com")

    assert_nil shorturl.short_url_code
  end

  test "short_url_code encodes persisted id" do
    shorturl = shorturls(:one)

    assert_equal Base62.encode(shorturl.id), shorturl.short_url_code
  end
end
