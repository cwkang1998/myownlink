require "application_system_test_case"

class ShorturlsTest < ApplicationSystemTestCase
  test "user views created shorturls on dashboard" do
    visit root_path

    assert_text "Fixture1"
    assert_text "https://example.com/one"
    assert_text "Fixture2"
    assert_text "https://example.com/two"
    assert_link "Create short URL"
  end

  test "user creates a shorturl and sees the details page" do
    with_target_title("CoinGecko Crypto Prices") do
      visit new_shorturl_path

      fill_in "Title", with: "CoinGecko"
      fill_in "Target URL", with: "https://www.coingecko.com"
      click_button "Create"

      assert_text "CoinGecko Crypto Prices"
      assert_text "https://www.coingecko.com"

      shorturl = Shorturl.find_by!(title: "CoinGecko Crypto Prices")
      assert_current_path shorturl_path(shorturl)
      assert_text redirect_shorturl_url(shorturl.short_url_code)
    end
  end

  test "user sees validation errors when creation fails" do
    visit new_shorturl_path

    fill_in "Title", with: ""
    fill_in "Target URL", with: "http://localhost/ABC123"
    click_button "Create"

    assert_text "Unable to create short URL."
    assert_text "Title can't be blank"
    assert_text "Target url must not be another shortened URL"
  end

  test "user opens a shorturl details page from dashboard" do
    shorturl = shorturls(:one)

    visit root_path
    click_on "Fixture1"

    assert_current_path shorturl_path(shorturl)
    assert_text shorturl.title
    assert_text shorturl.target_url
    assert_text redirect_shorturl_url(shorturl.short_url_code)
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
end
