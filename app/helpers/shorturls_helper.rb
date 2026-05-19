module ShorturlsHelper
  def full_short_url(shorturl)
    redirect_shorturl_url(code: shorturl.short_url_code)
  end
end
