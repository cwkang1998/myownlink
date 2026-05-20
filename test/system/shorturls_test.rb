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
    visit root_path
    target_url = "#{Capybara.current_session.server.base_url}/"

    visit new_shorturl_path
    fill_in "Target URL", with: target_url
    click_button "Create"

    assert_text "Site: #{target_url}"
    assert_text target_url

    shorturl = Shorturl.find_by!(target_url: target_url)
    assert_current_path shorturl_path(shorturl)
    assert_text redirect_shorturl_url(shorturl.short_url_code)
  end

  test "user creates a shorturl with default title when target title cannot be fetched" do
    visit root_path
    target_url = "#{Capybara.current_session.server.base_url}/no-title/page"

    visit new_shorturl_path
    fill_in "Target URL", with: target_url
    click_button "Create"

    assert_text "Site: #{target_url}"
    assert_text target_url

    shorturl = Shorturl.find_by!(target_url: target_url)
    assert_current_path shorturl_path(shorturl)
    assert_text redirect_shorturl_url(shorturl.short_url_code)
  end

  test "user sees validation errors when creation fails" do
    visit new_shorturl_path

    fill_in "Target URL", with: "http://localhost/ABC123"
    click_button "Create"

    assert_text "Unable to create short URL."
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

  test "user visits a shorturl and is redirected to the target url" do
    visit root_path
    target_url = "#{Capybara.current_session.server.base_url}/"
    shorturl = Shorturl.create!(title: "Local target", target_url: target_url)

    with_test_geocoder do
      assert_difference -> { ShorturlAccess.count }, 1 do
        visit redirect_shorturl_path(shorturl.short_url_code)
      end
    end

    assert_current_path root_path
    assert_link "Create short URL"
    assert_text "Local target"
  end

  private

  def with_test_geocoder
    Geocoder.configure(lookup: :test, ip_lookup: :test, cache: nil)
    Geocoder::Lookup::Test.reset
    Geocoder::Lookup::Test.add_stub("127.0.0.1", [])

    yield
  ensure
    Geocoder::Lookup::Test.reset
  end
end
