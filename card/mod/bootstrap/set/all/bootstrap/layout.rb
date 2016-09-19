
format :html do
  class BootstrapLayout
    def initialize format, opts={}, &block
      @format = format
      @rows = "".html_safe
      @opts = opts
      if block_given?
        define_singleton_method :generate_rows, block
        generate_rows
      end
    end

    def generate_layout
      @opts.delete(:container) ? container(@rows, @opts) : @rows
    end

    def container content, opts={}
      add_class opts, opts.delete(:fluid) ? "container-fluid" : "container"
      content_tag :div, content, opts
    end

    def row *args, &block
      opts, cols, @col_widths = process_row_args args
      @rows ||= "".html_safe
      @columns = "".html_safe
      cols ||= instance_exec(&block)
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
    def column content_or_opts={}, opts=nil, &block
      @columns ||= "".html_safe
      content, opts = if block_given?
                        [instance_exec(&block), content_or_opts]
                      else
                        [content_or_opts, opts || {}]
                      end
      add_class opts, "col-md-#{@col_widths.shift}"
      @columns << content_tag(:div, content.html_safe, opts)
    end

    def method_missing method_name, *args
      return super unless @format.respond_to? method_name
      @format.send method_name, *args
    end

    def respond_to_missing? method_name, _include_private=false
      @format.respond_to? method_name
    end
  end

  # generate bootstrap column layout
  # @example
  #   layout container: true, fluid: true, class: "hidden" do
  #     row 6, 6, class: "unicorn" do
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
  def layout opts={}, &block
    BootstrapLayout.new(self, opts, &block).generate_layout
  end
end
