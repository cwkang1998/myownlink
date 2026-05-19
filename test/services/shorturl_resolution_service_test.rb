require "test_helper"

class ShorturlResolutionServiceTest < ActiveSupport::TestCase
  test "resolves a short code to shorturl" do
    shorturl = shorturls(:one)

    resolved_shorturl = ShorturlResolutionService.call(short_url_code: shorturl.short_url_code)

    assert_equal shorturl, resolved_shorturl
    assert_equal shorturl.target_url, resolved_shorturl.target_url
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
end
