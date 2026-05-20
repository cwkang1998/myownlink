class ShorturlCreatorService < ApplicationService
  Result = Struct.new(:success?, :shorturl, keyword_init: true)

  def initialize(target_url:)
    @target_url = target_url
  end

  def call
    # Default to Site: + target url
    default_title = "Site: #{@target_url}"
    shorturl = Shorturl.new(title: default_title, target_url: @target_url)
    shorturl.validate
    return Result.new(success?: false, shorturl: shorturl) if shorturl.errors[:target_url].present?

    title = TargetTitleExtractorService.call(target_url: @target_url).presence

    ActiveRecord::Base.transaction do
      if title
        shorturl.title = title
      end
      shorturl.save!
    end
    Result.new(success?: true, shorturl: shorturl)

  rescue ActiveRecord::RecordInvalid => e
    Result.new(success?: false, shorturl: e.record)
  end
end
