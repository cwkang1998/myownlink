class ShorturlListService < ApplicationService
  Result = Struct.new(:shorturls, :page, :page_size, :total_pages, :pagination_pages, keyword_init: true)

  def initialize(page:, page_size:)
    @page = page
    @page_size = page_size
  end

  def call
    scope = Shorturl.order(created_at: :desc, id: :desc)
    pagination = Pagination.new(scope: scope, page: @page, page_size: @page_size)

    Result.new(
      shorturls: pagination.paginate,
      page: pagination.page,
      page_size: pagination.page_size,
      total_pages: pagination.total_pages,
      pagination_pages: pagination.visible_pages
    )
  end
end
