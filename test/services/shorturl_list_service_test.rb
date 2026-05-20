require "test_helper"

class ShorturlListServiceTest < ActiveSupport::TestCase
  test "returns paginated shorturls ordered by newest first" do
    shorturls = create_shorturls(22)

    result = ShorturlListService.call(page: 2, page_size: 10)

    assert_equal 2, result.page
    assert_equal 10, result.page_size
    assert_equal Shorturl.count, result.total_count
    assert_equal (Shorturl.count.to_f / 10).ceil, result.total_pages
    assert_equal [ 1, 2, 3 ], result.pagination_pages
    assert_equal shorturls[10, 10], result.shorturls.to_a
  end

  test "bounds requested page to last available page" do
    create_shorturls(12)

    result = ShorturlListService.call(page: 99, page_size: 10)

    assert_equal result.total_pages, result.page
  end

  private

  def create_shorturls(count)
    count.times.map do |index|
      Shorturl.create!(
        title: "List Service Link #{index}",
        target_url: "https://example.com/list-service-#{index}",
        created_at: (count - index).days.from_now,
        updated_at: (count - index).days.from_now
      )
    end
  end
end
