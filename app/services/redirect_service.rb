class RedirectService < ApplicationService
  Result = Struct.new(:success?, :resolved_target_url, keyword_init: true)

  def initialize(request:, short_url_code:)
    @request = request
    @short_url_code = short_url_code
  end

  def call
    target_url = nil
    ActiveRecord::Base.transaction do
      resolved_shorturl = ShorturlResolutionService.call(short_url_code: @short_url_code)
      target_url = resolved_shorturl.target_url

      AccessRecordService.call(shorturl_id: resolved_shorturl.shorturl_id, request: @request)
    end
    Result.new(success?: true, resolved_target_url: target_url)

  rescue Base62::Error
    Rails.logger.info("Fail to decode shorturl code: #{@short_url_code}")
    Result.new(success?: false, resolved_target_url: nil)
  rescue ActiveRecord::RecordNotFound
    Rails.logger.info("Fail to resolve shorturl: /#{@short_url_code}")
    Result.new(success?: false, resolved_target_url: nil)
  end
end
