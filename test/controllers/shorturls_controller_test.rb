require "test_helper"

class ShorturlsControllerTest < ActionDispatch::IntegrationTest
  test "index renders dashboard with shorturls" do
    get root_url

    assert_response :success
    assert_select "li", count: shorturls.count
  end

  test "new renders creation form" do
    get new_shorturl_url

    assert_response :success
    assert_select "form[action=?][method=?]", shorturls_path, "post"
    assert_select "input[name=?]", "shorturl[title]"
    assert_select "input[name=?]", "shorturl[target_url]"
  end

  test "create persists shorturl and redirects to details" do
    assert_difference -> { Shorturl.count }, 1 do
      post shorturls_url, params: {
        shorturl: {
          title: "CoinGecko",
          target_url: "https://www.coingecko.com"
        }
      }
    end

    assert_redirected_to shorturl_url(Shorturl.order(:created_at).last)
  end

  test "create renders validation errors for invalid params" do
    assert_no_difference -> { Shorturl.count } do
      post shorturls_url, params: {
        shorturl: {
          title: "",
          target_url: "not-a-url"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select ".text-red-700", text: /Unable to create short URL/
    assert_select ".text-red-700", text: /Title can't be blank/
    assert_select ".text-red-700", text: /Target url must be a valid URL/
  end

  test "show renders shorturl details" do
    shorturl = shorturls(:one)
    access = shorturl_accesses(:one)

    get shorturl_url(shorturl)

    assert_response :success
    assert_includes response.body, shorturl.title
    assert_includes response.body, shorturl.target_url
    assert_includes response.body, redirect_shorturl_url(shorturl.short_url_code)
    assert_select "#vistor_count", { text: "1" }
    assert_select "th", text: "Timestamp"
    assert_select "td", text: access.timestamp.strftime("%Y-%m-%d %H:%M:%S %Z")
    assert_select "th", text: "Geolocation"
    assert_select "td", text: access.geolocation
  end

  test "redirect_shorturl redirects to target url" do
    shorturl = shorturls(:one)

    assert_difference -> { ShorturlAccess.count }, 1 do
      get redirect_shorturl_url(shorturl.short_url_code)
    end

    assert_redirected_to shorturl.target_url
  end

  test "redirect_shorturl renders not found for missing shorturl" do
    missing_code = Base62.encode(Shorturl.maximum(:id) + 1)

    assert_no_difference -> { ShorturlAccess.count } do
      get redirect_shorturl_url(missing_code)
    end

    assert_response :not_found
  end
end
