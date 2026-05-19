class ShorturlCreatorService < ApplicationService
  Result = Struct.new(:success?, :shorturl, keyword_init: true)

  def initialize(title:, target_url:)
    @title = title
    @target_url = target_url
  end

  def call
    shorturl = nil

    ActiveRecord::Base.transaction do
      shorturl = Shorturl.create!(
        title: @title,
        target_url: @target_url
      )
    end
    Result.new(success?: true, shorturl: shorturl)

  rescue ActiveRecord::RecordInvalid => e
    Result.new(success?: false, shorturl: e.record)
  end
end
