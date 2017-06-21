class Bootstrap
  class Component
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
    #     add_html "<span> some extra html</span>"
    #     row 6, 6, ["unicorn", "rainbow"], class: "horn"
    #   end
    class Layout < Component
      def render_content
        content = instance_exec *@args, &@build_block
        add_content content
        opts = @args.first
        return unless opts && opts.delete(:container)
        content = @content.pop
        @content = ["".html_safe]
        container content, opts
      end

      add_div_method :container, nil do |opts, _extra_args|
        prepend_class opts, opts.delete(:fluid) ? "container-fluid" : "container"
        opts
      end

      # @param *args column widths, column content and html attributes
      # @example
      #   row 6, 6, ["col one", "col two"], class: "count", id: "count"
      # @example
      #   row md: 12, xs: 8, "single column content"
      # @example
      #   row md: [1, 11], xs: [2, 10] do
      #     col "A"
      #     col "B"
      #   end
      add_div_method :row, "row", content_processor: :column do |opts, extra_args|
        cols_content = extra_args.pop if extra_args.last.is_a? Array
        [opts, col_widths(extra_args, opts), cols_content].compact
      end

      # default column width type is for medium devices (col-md-)
      add_div_method :column, nil do |opts, _extra_args|
        @child_args.last.each do |medium, size|
          prepend_class opts, "col-#{medium}-#{size.shift}"
        end
        opts
      end

      alias_method :col, :column

      private

      def standardize_row_args args
        opts = args.last.is_a?(Hash) ? args.pop : {}
        cols = (args.last.is_a?(Array) || args.last.is_a?(String)) &&
               Array.wrap(args.pop)
        [cols, opts, col_widths(args, opts)]
      end

      def col_widths args, opts
        opts = args.pop if args.one? && args.last.is_a?(Hash)
        if args.present?
          raise Error, "bad argument" unless args.all? { |a| a.is_a? Integer }
          { md: Array.wrap(args) }
        else
          %i[lg xs sm md].each_with_object({}) do |k, cols_w|
            next unless (widths = opts.delete(k))
            cols_w[k] = Array.wrap widths
          end
        end
      end
    end
  end
end
