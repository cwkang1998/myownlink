require "test_helper"

class ShorturlCreatorServiceTest < ActiveSupport::TestCase
  test "creates a shorturl with valid attributes" do
    result = nil

    assert_difference -> { Shorturl.count }, 1 do
      result = ShorturlCreatorService.call(
        title: "CoinGecko",
        target_url: "https://www.coingecko.com"
      )
    end

    assert result.success?
    assert_predicate result.shorturl, :persisted?
    assert_equal "CoinGecko", result.shorturl.title
    assert_equal "https://www.coingecko.com", result.shorturl.target_url
    assert_equal Base62.encode(result.shorturl.id), result.shorturl.short_url_code
  end

  test "returns invalid shorturl without persisting invalid attributes" do
    result = nil

    assert_no_difference -> { Shorturl.count } do
      result = ShorturlCreatorService.call(title: "", target_url: "not-a-url")
    end

    assert_not result.success?
    assert_not_predicate result.shorturl, :persisted?
    assert_includes result.shorturl.errors[:title], "can't be blank"
    assert_includes result.shorturl.errors[:target_url], "must be a valid URL"
  end
end
