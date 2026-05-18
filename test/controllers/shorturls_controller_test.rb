require "test_helper"

class ShorturlControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_response :success
  end

  test "should get new" do
    get new_shorturl_url
    assert_response :success
  end

  test "should get show" do
    get shorturl_url
    assert_response :success
  end

  test "should get redirect_shorturl" do
    get redirect_shorturl_url
    assert_response :success
  end
end
