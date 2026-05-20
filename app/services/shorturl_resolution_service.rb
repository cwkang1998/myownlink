class ShorturlResolutionService < ApplicationService
  POSTGRES_BIGINT_MAX = 9_223_372_036_854_775_807
  SHORTURLS_CACHE = ActiveSupport::Cache::MemoryStore.new(
    size: 5.megabytes,
    expires_in: 12.hours
  )
  ResolvedShorturl = Struct.new(:target_url, :shorturl_id, keyword_init: true)

  def initialize(short_url_code:)
    @short_url_code = short_url_code
  end

  def call
    SHORTURLS_CACHE.fetch("shorturl:#{@short_url_code}") do
      decoded_id = Base62.decode(@short_url_code)

      # This additional check is needed because our code max length is 15,
      # with 62**15 possibility, thus larger than the max bigint value for postgres.
      raise ActiveRecord::RecordNotFound if decoded_id > POSTGRES_BIGINT_MAX

      shorturl = Shorturl.find(decoded_id)
      ResolvedShorturl.new(target_url: shorturl.target_url, shorturl_id: shorturl.id)
    end
  end
end
