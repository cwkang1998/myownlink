require "test_helper"

class ShorturlsControllerTest < ActionDispatch::IntegrationTest
  test "index renders dashboard with shorturls" do
    shorturl = shorturls(:one)
    short_url = redirect_shorturl_url(shorturl.short_url_code)

    get root_url

    assert_response :success
    assert_select "title", text: "myownl.ink: Dashboard"
    assert_select "h1", text: "Dashboard"
    assert_select "p", text: "Total links", count: 0
    assert_select "li", count: shorturls.count
    assert_select "a[href=?]", shorturl_path(shorturl), text: /#{Regexp.escape(shorturl.title)}/
    assert_select "a[href=?]", short_url, count: 0
    assert_select "p", text: short_url
  end

  test "index paginates shorturls with page and page_size" do
    paged_shorturls = 22.times.map do |index|
      Shorturl.create!(
        id: 1_000_000_000 + index,
        title: "Paged Link #{index}",
        target_url: "https://example.com/paged-#{index}",
        created_at: (20 - index).days.from_now,
        updated_at: (20 - index).days.from_now
      )
    end

    get root_url(page: 2, page_size: 10)

    assert_response :success
    assert_includes response.body, paged_shorturls[10].title
    assert_not_includes response.body, paged_shorturls[9].title
    assert_select "span[aria-current=?]", "page", text: "2"
    assert_select "a[href=?]", root_path(page: 1, page_size: 10), text: "1"
    assert_select "a[href=?]", root_path(page: 3, page_size: 10), text: "3"
  end

  test "index renders first last adjacent pages and gaps for larger page sets" do
    90.times do |index|
      Shorturl.create!(
        id: 1_000_100_000 + index,
        title: "Paged Link #{index}",
        target_url: "https://example.com/paged-#{index}",
        created_at: (index + 1).days.from_now,
        updated_at: (index + 1).days.from_now
      )
    end
    total_pages = (Shorturl.count.to_f / 10).ceil

    get root_url(page: 5, page_size: 10)

    assert_response :success
    assert_select "span[aria-current=?]", "page", text: "5"
    assert_select "a[href=?]", root_path(page: 1, page_size: 10), text: "1"
    assert_select "a[href=?]", root_path(page: 4, page_size: 10), text: "4"
    assert_select "a[href=?]", root_path(page: 6, page_size: 10), text: "6"
    assert_select "a[href=?]", root_path(page: total_pages, page_size: 10), text: total_pages.to_s
    assert_select "a[href=?]", root_path(page: 2, page_size: 10), count: 0
    assert_select "span", text: "...", count: 2
  end

  test "new renders creation form" do
    get new_shorturl_url

    assert_response :success
    assert_select "title", text: "myownl.ink: Create short URL"
    assert_select "h1", text: "Create short URL"
    assert_select "form[action=?][method=?]", shorturls_path, "post"
    assert_select "input[name=?]", "shorturl[target_url]"
  end

  test "create persists shorturl and redirects to details" do
    with_target_title("CoinGecko Crypto Prices") do
      assert_difference -> { Shorturl.count }, 1 do
        post shorturls_url, params: {
          shorturl: {
            title: "CoinGecko",
            target_url: "https://www.coingecko.com"
          }
        }
      end
    end

    shorturl = Shorturl.order(:created_at).last
    assert_equal "CoinGecko Crypto Prices", shorturl.title
    assert_redirected_to shorturl_url(shorturl)
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
    assert_select ".text-red-700", text: /Unable to create short URL/
    assert_select ".text-red-700", text: /Target url must be a valid URL/
  end

  test "show renders shorturl details" do
    shorturl = shorturls(:one)
    access = shorturl_accesses(:one)

    get shorturl_url(shorturl)

    assert_response :success
    assert_select "title", text: "myownl.ink: #{shorturl.title}"
    assert_select "p", text: "Short URL Details"
    assert_select "h1.text-3xl", text: shorturl.title
    assert_select "p.mt-2.text-sm.leading-6.text-slate-600", text: "Created #{shorturl.created_at.strftime("%Y-%m-%d")}"
    assert_includes response.body, shorturl.title
    assert_includes response.body, shorturl.target_url
    assert_includes response.body, redirect_shorturl_url(shorturl.short_url_code)
    assert_select "#visitor_count", { text: "1" }
    assert_select "th", text: "Visit time"
    assert_select "p.font-medium.text-slate-900", text: access.timestamp.strftime("%Y-%m-%d %H:%M:%S %Z")
    assert_select "p.text-xs.text-slate-500", text: /ago/
    assert_select "th", text: "Location"
    assert_select "td", text: access.geolocation
  end

  test "show paginates shorturl visits with page and page_size" do
    shorturl = shorturls(:one)
    paged_accesses = 22.times.map do |index|
      ShorturlAccess.create!(
        id: 1_000_000_000 + index,
        shorturl: shorturl,
        timestamp: Time.zone.parse("2030-01-01 00:00:00 UTC") + (30 - index).days,
        geolocation: "Paged Visit #{index}"
      )
    end

    get shorturl_url(shorturl, page: 2, page_size: 10)

    assert_response :success
    assert_select "#visitor_count", text: ShorturlAccess.where(shorturl_id: shorturl.id).count.to_s
    assert_includes response.body, paged_accesses[10].geolocation
    assert_not_includes response.body, paged_accesses[9].geolocation
    assert_select "span[aria-current=?]", "page", text: "2"
    assert_select "a[href=?]", shorturl_path(shorturl, page: 1, page_size: 10), text: "1"
    assert_select "a[href=?]", shorturl_path(shorturl, page: 3, page_size: 10), text: "3"
  end

  test "show renders not found for missing shorturl" do
    get shorturl_url(Shorturl.maximum(:id) + 1)

    assert_response :not_found
  end

  test "redirect_shorturl redirects to target url" do
    shorturl = shorturls(:one)

    assert_difference -> { ShorturlAccess.count }, 1 do
      get redirect_shorturl_url(shorturl.short_url_code)
    end

    assert_redirected_to shorturl.target_url
  end

  test "redirect_shorturl renders not found for missing shorturl" do
    missing_code = Base62.encode(Shorturl.maximum(:id) + 1)

    assert_no_difference -> { ShorturlAccess.count } do
      get redirect_shorturl_url(missing_code)
    end

    assert_response :not_found
  end

  test "redirect_shorturl renders not found for oversized decoded short code" do
    assert_no_difference -> { ShorturlAccess.count } do
      get redirect_shorturl_url("z" * Base62::MAX_LENGTH)
    end

    assert_response :not_found
  end

  private

  def with_target_title(title)
    original_call = TargetTitleExtractorService.method(:call)

    TargetTitleExtractorService.define_singleton_method(:call) do |**_kwargs|
      title
    end

    yield
  ensure
    TargetTitleExtractorService.define_singleton_method(:call) do |*args, **kwargs|
      original_call.call(*args, **kwargs)
    end
  end
end
