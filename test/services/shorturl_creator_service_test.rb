require "test_helper"

class ShorturlCreatorServiceTest < ActiveSupport::TestCase
  test "creates a shorturl with valid attributes" do
    result = nil

    with_target_title("CoinGecko Crypto Prices") do
      assert_difference -> { Shorturl.count }, 1 do
        result = ShorturlCreatorService.call(
          target_url: "https://www.coingecko.com"
        )
      end
    end

    assert result.success?
    assert_predicate result.shorturl, :persisted?
    assert_equal "CoinGecko Crypto Prices", result.shorturl.title
    assert_equal "https://www.coingecko.com", result.shorturl.target_url
    assert_equal Base62.encode(result.shorturl.id), result.shorturl.short_url_code
  end

  test "falls back to default title when target title cannot be extracted" do
    result = nil

    with_target_title(nil) do
      assert_difference -> { Shorturl.count }, 1 do
        result = ShorturlCreatorService.call(
          target_url: "https://www.coingecko.com"
        )
      end
    end

    assert result.success?
    assert_equal "Site: https://www.coingecko.com", result.shorturl.title
  end

  test "returns invalid shorturl without persisting invalid attributes" do
    result = nil

    without_target_title_extraction do
      assert_no_difference -> { Shorturl.count } do
        result = ShorturlCreatorService.call(target_url: "not-a-url")
      end
    end

    assert_not result.success?
    assert_not_predicate result.shorturl, :persisted?
    assert_includes result.shorturl.errors[:target_url], "must be a valid URL"
  end

  private

  def with_target_title(title)
    original_call = TargetTitleExtractorService.method(:call)

    TargetTitleExtractorService.define_singleton_method(:call) do |**_kwargs|
      title
    end

    yield
  ensure
    TargetTitleExtractorService.define_singleton_method(:call) do |*args, **kwargs|
      original_call.call(*args, **kwargs)
    end
  end

  def without_target_title_extraction
    original_call = TargetTitleExtractorService.method(:call)

    TargetTitleExtractorService.define_singleton_method(:call) do |**_kwargs|
      raise "target title extraction should not run"
    end

    yield
  ensure
    TargetTitleExtractorService.define_singleton_method(:call) do |*args, **kwargs|
      original_call.call(*args, **kwargs)
    end
  end
end
