#! no set module

# render paging links
class PagingLinks
  def initialize total_pages, current_page
    @total = total_pages
    @current = current_page
  end

  # @param window [integer] number of page links shown left and right
  #   of the current page
  # @example: current page = 5, window = 2
  #   |<<|1|...|3|4|[5]|6|7|...|10|>>|
  # @yield [text, page, status, options] block to build single paging link
  # @yieldparam status [Symbol] :active (for current page) or :disabled
  # @yieldparam page [Integer] page number, first page is 0
  # @return [Array<String>]
  def build window=2, &block
    @render_item = block
    links window
  end

  private

  def links window
    @window_start = [@current - window, 0].max
    @window_end = [@current + window, @total].min
    left_part + window_part + right_part
  end

  # the links around the current page
  def window_part
    (@window_start..@window_end).map do |page|
      direct_page_link page
    end.compact
  end

  def left_part
    [
      previous_page_link,
      (direct_page_link 0 if @window_start > 0),
      (ellipse if @window_start > 1)
    ].compact
  end

  def right_part
    [
      (ellipse if @total > @window_end + 1),
      (direct_page_link @total if @total > @window_end),
      next_page_link
    ].compact
  end

  def previous_page_link
    paging_item '<span aria-hidden="true">&laquo;</span>', previous_page,
                "aria-label" => "Previous"
  end

  def next_page_link
    paging_item '<span aria-hidden="true">&raquo;</span>', next_page,
                "aria-label" => "Next"
  end

  def direct_page_link page
    return unless page >= 0 && page <= @total
    paging_item page + 1, page
  end

  def ellipse
    @render_item.call "<span>...</span>", false
  end

  def paging_item text, page, options={}
    status =
      if page == @current
        :active
      elsif !page
        :disabled
      end
    @render_item.call text, page, status, options
  end

  def previous_page
    @current > 0 ? @current - 1 : false
  end

  def next_page
    @current < @total ? @current + 1 : false
  end
end
