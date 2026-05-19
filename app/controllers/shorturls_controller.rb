class ShorturlsController < ApplicationController
  def index
    @shorturls = Shorturl.order(created_at: :desc).all
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
    @shorturl = Shorturl.find(params[:id])
  end

  def redirect_shorturl
    result = RedirectService.call(request: request, short_url_code: params[:code])

    return render_404 unless result.success?

    redirect_to result.resolved_target_url, allow_other_host: true
  end

  private

  def create_params
    params.require(:shorturl).permit(:title, :target_url)
  end

  def render_404
    render file: Rails.public_path.join("404.html"), status: :not_found, layout: false
  end
end
