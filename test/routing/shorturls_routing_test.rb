require "test_helper"

class ShorturlsRoutingTest < ActionDispatch::IntegrationTest
  test "short code route resolves to redirect action" do
    assert_routing "/abc123", controller: "shorturls", action: "redirect_shorturl", code: "abc123"
  end

  test "shorturl resource routes are not captured by short code route" do
    assert_routing "/shorturls/new", controller: "shorturls", action: "new"
    assert_routing "/shorturls/1", controller: "shorturls", action: "show", id: "1"
  end

  test "health check route is not captured by short code route" do
    assert_routing "/up", controller: "rails/health", action: "show"
  end

  test "invalid short code path is not routable" do
    assert_raises(ActionController::RoutingError) do
      Rails.application.routes.recognize_path("/not-valid!")
    end
  end

  test "overly long short code path is not routable" do
    assert_raises(ActionController::RoutingError) do
      Rails.application.routes.recognize_path("/1234567890abcdef")
    end
  end
end
