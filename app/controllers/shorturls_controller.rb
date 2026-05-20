class ShorturlsController < ApplicationController
  DEFAULT_PAGE_SIZE = 10
  ALLOWED_PAGE_SIZE = [ 10, 25, 50 ].freeze

  def index
    result = ShorturlListService.call(page: page_param, page_size: page_size_param)

    @page = result.page
    @page_size = result.page_size
    @total_pages = result.total_pages
    @pagination_pages = result.pagination_pages
    @shorturls = result.shorturls
  end

  def new
  end

  def create
    result = ShorturlCreatorService.call(**create_params.to_h.symbolize_keys)

    @new_shorturl = result.shorturl

    if result.success?
      redirect_to @new_shorturl, notice: "Successfully created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    result = AccessListService.call(shorturl_id: params[:id], page: page_param, page_size: page_size_param)

    return render_404 unless result.success?

    @shorturl = result.shorturl
    @page = result.page
    @page_size = result.page_size
    @visitor_count = result.visitor_count
    @total_pages = result.total_pages
    @pagination_pages = result.pagination_pages
    @shorturl_accesses = result.shorturl_accesses
  end

  def redirect_shorturl
    result = RedirectService.call(request: request, short_url_code: params[:code])

    return render_404 unless result.success?

    redirect_to result.resolved_target_url, allow_other_host: true
  end

  private

  def page_param
    requested_page = Integer(params.fetch(:page, 1), exception: false)

    requested_page.present? && requested_page.positive? ? requested_page : 1
  end

  def page_size_param
    requested_page_size = Integer(params.fetch(:page_size, DEFAULT_PAGE_SIZE), exception: false)

    return DEFAULT_PAGE_SIZE unless ALLOWED_PAGE_SIZE.include?(requested_page_size)

    requested_page_size
  end

  def create_params
    params.require(:shorturl).permit(:target_url)
  end

  def render_404
    render file: Rails.public_path.join("404.html"), status: :not_found, layout: false
  end
end
