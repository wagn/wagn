
format :html do
  # generate bootstrap column layout
  # @example
  #   layout container: true, fluid: true, class: "hidden" do
  #     row 6, 6, class: "unicorn"
  #       column "horn",
  #       column "rainbow", class: "colorful"
  #     end
  #   end
  # @example
  #   layout do
  #     row 3, 3, 4, 2, class: "unicorn" do
  #       [ "horn", "body", "tail", "rainbow"]
  #     end
  #     row 6, 6, ["unicorn", "rainbow"], class: "horn"
  #   end
  def layout opts={}
    @rows = "".html_safe
    yield
    opts.delete(:container) ? container(@rows, opts) : @rows
  end

  def container content, opts={}
    add_class opts, opts.delete(:fluid) ? "container-fluid" : "container"
    content_tag :div, content, opts
  end

  def row *args
    opts, cols, @col_widths = process_row_args args
    @rows ||= "".html_safe
    @columns = "".html_safe
    cols ||= yield
    cols.each { |col_content| column(col_content) } if cols.is_a? Array
    add_class opts, "row"
    @rows << content_tag(:div, @columns, opts)
  end

  def process_row_args args
    opts = args.last.is_a?(Hash) ? args.pop : {}
    cols = args.last.is_a?(Array) && args.pop
    [opts, cols, check_col_widths(args)]
  end

  def check_col_widths args
    raise Error, "bad argument" unless args.all? { |a| a.is_a? Fixnum }
    total_width = args.inject(0) { |a, e| a + e }
    raise Error, "column widths must sum up to 12" unless total_width == 12
    args
  end

  # default column width type is for medium devices (col-md-)
  def column content, opts={}
    @columns ||= "".html_safe
    add_class opts, "col-md-#{@col_widths.shift}"
    @columns << content_tag(:div, content.html_safe, opts)
  end
end
