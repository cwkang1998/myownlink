require "test_helper"

class ShorturlResolutionServiceTest < ActiveSupport::TestCase
  setup do
    ShorturlResolutionService::SHORTURLS_CACHE.clear
  end

  teardown do
    ShorturlResolutionService::SHORTURLS_CACHE.clear
  end

  test "resolves a short code to target url and shorturl id" do
    shorturl = shorturls(:one)

    resolved_shorturl = ShorturlResolutionService.call(short_url_code: shorturl.short_url_code)

    assert_instance_of ShorturlResolutionService::ResolvedShorturl, resolved_shorturl
    assert_equal shorturl.id, resolved_shorturl.shorturl_id
    assert_equal shorturl.target_url, resolved_shorturl.target_url
  end

  test "returns cached resolved shorturl after first lookup" do
    shorturl = shorturls(:one)

    resolved_shorturl = ShorturlResolutionService.call(short_url_code: shorturl.short_url_code)

    with_shorturl_find(->(_id) { flunk "expected cached resolved shorturl without database lookup" }) do
      cached_shorturl = ShorturlResolutionService.call(short_url_code: shorturl.short_url_code)

      assert_equal resolved_shorturl, cached_shorturl
      assert_equal shorturl.id, cached_shorturl.shorturl_id
      assert_equal shorturl.target_url, cached_shorturl.target_url
    end
  end

  test "uses separate cache entries for different short codes" do
    cached_shorturl = shorturls(:one)
    uncached_shorturl = shorturls(:two)
    looked_up_ids = []

    ShorturlResolutionService.call(short_url_code: cached_shorturl.short_url_code)

    with_shorturl_find(->(id) {
      looked_up_ids << id
      uncached_shorturl
    }) do
      cached_result = ShorturlResolutionService.call(short_url_code: cached_shorturl.short_url_code)
      uncached_result = ShorturlResolutionService.call(short_url_code: uncached_shorturl.short_url_code)

      assert_equal cached_shorturl.id, cached_result.shorturl_id
      assert_equal cached_shorturl.target_url, cached_result.target_url
      assert_equal uncached_shorturl.id, uncached_result.shorturl_id
      assert_equal uncached_shorturl.target_url, uncached_result.target_url
    end

    assert_equal [ uncached_shorturl.id ], looked_up_ids
  end

  test "raises when short code cannot be decoded" do
    assert_raises(Base62::Error) do
      ShorturlResolutionService.call(short_url_code: "not-valid!")
    end
  end

  test "raises when decoded short code does not exist" do
    missing_code = Base62.encode(Shorturl.maximum(:id) + 1)

    assert_raises(ActiveRecord::RecordNotFound) do
      ShorturlResolutionService.call(short_url_code: missing_code)
    end
  end

  test "raises not found when decoded short code is outside postgres bigint range" do
    assert Base62.decode("z" * Base62::MAX_LENGTH) > ShorturlResolutionService::POSTGRES_BIGINT_MAX

    assert_raises(ActiveRecord::RecordNotFound) do
      ShorturlResolutionService.call(short_url_code: "z" * Base62::MAX_LENGTH)
    end
  end

  private

  def with_shorturl_find(replacement)
    original_find = Shorturl.method(:find)

    Shorturl.define_singleton_method(:find) do |*args, **kwargs|
      replacement.call(*args, **kwargs)
    end

    yield
  ensure
    Shorturl.define_singleton_method(:find) do |*args, **kwargs|
      original_find.call(*args, **kwargs)
    end
  end
end
