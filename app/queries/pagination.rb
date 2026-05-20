class Pagination
  attr_reader :page, :page_size, :total_count

  def initialize(scope:, page:, page_size:)
    @scope = scope
    @page_size = page_size
    @total_count = @scope.count
    @page = bounded_page(page)
  end

  def paginate
    @scope.offset((@page - 1) * @page_size).limit(@page_size)
  end

  def total_pages
    return 1 if @total_count.zero?

    (@total_count.to_f / @page_size).ceil
  end

  def visible_pages
    visible_pages = if total_pages <= 5
      (1..total_pages).to_a
    else
      ([ 1, total_pages ] + ((@page - 1)..(@page + 1)).to_a).select do |page_number|
        page_number.between?(1, total_pages)
      end.uniq.sort
    end

    visible_pages.each_with_object([]) do |page_number, pages|
      pages << :gap if pages.any? && page_number > pages.last + 1
      pages << page_number
    end
  end

  private

  def bounded_page(page)
    [ [ page, 1 ].max, total_pages ].min
  end
end
