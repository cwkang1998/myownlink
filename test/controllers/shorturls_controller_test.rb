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
    assert_select ".text-app-error", text: /Unable to create short URL/
    assert_select ".text-app-error", text: /Title can't be blank/
    assert_select ".text-app-error", text: /Target url must be a valid URL/
  end

  test "show renders shorturl details" do
    shorturl = shorturls(:one)

    get shorturl_url(shorturl)

    assert_response :success
    assert_includes response.body, shorturl.title
    assert_includes response.body, shorturl.target_url
  end
end
