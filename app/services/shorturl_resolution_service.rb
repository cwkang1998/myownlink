class ShorturlResolutionService < ApplicationService
  def initialize(short_url_code:)
    @short_url_code = short_url_code
  end

  def call
    shorturl = Shorturl.find(Base62.decode(@short_url_code))

    shorturl
  end
end
