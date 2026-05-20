require "test_helper"

class AccessListServiceTest < ActiveSupport::TestCase
  test "returns paginated accesses for the requested shorturl ordered by newest first" do
    shorturl = shorturls(:one)
    other_shorturl = shorturls(:two)
    accesses = create_accesses(shorturl, 22)
    ShorturlAccess.create!(
      shorturl: other_shorturl,
      timestamp: Time.zone.parse("2040-01-01 00:00:00 UTC"),
      geolocation: "Other Shorturl"
    )

    result = AccessListService.call(shorturl_id: shorturl.id, page: 2, page_size: 10)

    assert_equal 2, result.page
    assert_equal 10, result.page_size
    assert_equal ShorturlAccess.where(shorturl_id: shorturl.id).count, result.visitor_count
    assert_equal (result.visitor_count.to_f / 10).ceil, result.total_pages
    assert_equal [ 1, 2, 3 ], result.pagination_pages
    assert_equal accesses[10, 10], result.shorturl_accesses.to_a
    assert_not_includes result.shorturl_accesses, ShorturlAccess.find_by!(geolocation: "Other Shorturl")
  end

  test "bounds requested page to last available page" do
    shorturl = shorturls(:one)
    create_accesses(shorturl, 12)

    result = AccessListService.call(shorturl_id: shorturl.id, page: 99, page_size: 10)

    assert_equal result.total_pages, result.page
  end

  test "returns failure result when shorturl does not exist" do
    result = AccessListService.call(shorturl_id: Shorturl.maximum(:id) + 1, page: 1, page_size: 10)

    assert_not result.success?
    assert_nil result.shorturl
    assert_nil result.shorturl_accesses
    assert_equal 1, result.page
    assert_equal 10, result.page_size
    assert_equal 1, result.total_pages
    assert_nil result.pagination_pages
    assert_nil result.visitor_count
  end

  private

  def create_accesses(shorturl, count)
    count.times.map do |index|
      ShorturlAccess.create!(
        shorturl: shorturl,
        timestamp: Time.zone.parse("2030-01-01 00:00:00 UTC") + (count - index).days,
        geolocation: "List Service Visit #{index}"
      )
    end
  end
end
