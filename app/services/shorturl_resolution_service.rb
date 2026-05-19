class ShorturlResolutionService < ApplicationService
  POSTGRES_BIGINT_MAX = 9_223_372_036_854_775_807

  def initialize(short_url_code:)
    @short_url_code = short_url_code
  end

  def call
    decoded_id = Base62.decode(@short_url_code)

    # This additional check is needed because our code max length is 15,
    # with 62**15 possibility, thus larger than the max bigint value for postgres.
    raise ActiveRecord::RecordNotFound if decoded_id > POSTGRES_BIGINT_MAX

    Shorturl.find(decoded_id)
  end
end
