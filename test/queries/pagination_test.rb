require "test_helper"
require "securerandom"

class PaginationTest < ActiveSupport::TestCase
  test "paginates the provided scope" do
    scope, shorturls = create_shorturls(12)
    pagination = Pagination.new(scope: scope, page: 2, page_size: 10)

    assert_equal 2, pagination.page
    assert_equal 10, pagination.page_size
    assert_equal 12, pagination.total_count
    assert_equal 2, pagination.total_pages
    assert_equal shorturls[10..], pagination.paginate.to_a
  end

  test "uses one total page for empty scopes" do
    pagination = Pagination.new(scope: Shorturl.none, page: 1, page_size: 10)

    assert_equal 1, pagination.page
    assert_equal 0, pagination.total_count
    assert_equal 1, pagination.total_pages
    assert_empty pagination.paginate
    assert_equal [ 1 ], pagination.visible_pages
  end

  test "bounds requested page to available page range" do
    scope, = create_shorturls(12)

    high_page = Pagination.new(scope: scope, page: 99, page_size: 10)
    low_page = Pagination.new(scope: scope, page: 0, page_size: 10)

    assert_equal 2, high_page.page
    assert_equal 1, low_page.page
  end

  test "returns every visible page when total pages are five or fewer" do
    scope, = create_shorturls(50)
    pagination = Pagination.new(scope: scope, page: 3, page_size: 10)

    assert_equal [ 1, 2, 3, 4, 5 ], pagination.visible_pages
  end

  test "returns first last adjacent pages and gaps for larger page sets" do
    scope, = create_shorturls(100)
    pagination = Pagination.new(scope: scope, page: 5, page_size: 10)

    assert_equal [ 1, :gap, 4, 5, 6, :gap, 10 ], pagination.visible_pages
  end

  test "omits leading gap when current page is near the start" do
    scope, = create_shorturls(100)
    pagination = Pagination.new(scope: scope, page: 2, page_size: 10)

    assert_equal [ 1, 2, 3, :gap, 10 ], pagination.visible_pages
  end

  test "omits trailing gap when current page is near the end" do
    scope, = create_shorturls(100)
    pagination = Pagination.new(scope: scope, page: 9, page_size: 10)

    assert_equal [ 1, :gap, 8, 9, 10 ], pagination.visible_pages
  end

  private

  def create_shorturls(count)
    prefix = "Pagination Test #{SecureRandom.hex(8)}"

    shorturls = count.times.map do |index|
      Shorturl.create!(
        title: "#{prefix} #{index}",
        target_url: "https://example.com/paged-#{index}",
        created_at: (count - index).days.from_now,
        updated_at: (count - index).days.from_now
      )
    end

    [ Shorturl.where(id: shorturls.map(&:id)).order(created_at: :desc, id: :desc), shorturls ]
  end
end
