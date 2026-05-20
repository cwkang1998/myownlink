class AccessListService < ApplicationService
  Result = Struct.new(:success?, :shorturl, :shorturl_accesses, :page, :page_size, :total_pages, :pagination_pages, :visitor_count, keyword_init: true)

  def initialize(shorturl_id:, page:, page_size:)
    @shorturl_id = shorturl_id
    @page = page
    @page_size = page_size
  end

  def call
    shorturl = Shorturl.find(@shorturl_id)

    scope = ShorturlAccess.where(shorturl_id: @shorturl_id).order(timestamp: :desc, created_at: :desc, id: :desc)
    pagination = Pagination.new(scope: scope, page: @page, page_size: @page_size)

    Result.new(
      success?: true,
      shorturl: shorturl,
      shorturl_accesses: pagination.paginate,
      page: pagination.page,
      page_size: pagination.page_size,
      total_pages: pagination.total_pages,
      pagination_pages: pagination.visible_pages,
      visitor_count: pagination.total_count
    )
  rescue ActiveRecord::RecordNotFound
    Result.new(
      success?: false,
      shorturl: nil,
      shorturl_accesses: nil,
      page: @page,
      page_size: @page_size,
      total_pages: 1,
      pagination_pages: nil,
      visitor_count: nil
    )
  end
end
