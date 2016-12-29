format :html do
  class TableHelper
    def initialize format, content, opts={}
      @format = format
      @div_table = opts.delete :div_table
      if opts[:header]
        @header = opts[:header].is_a?(Array) ? opts[:header] : content.shift
      end
      @rows = content
      @opts = opts
      @format.add_class opts, :table
    end

    def render
      tag :table, class: @opts[:class] do
        [header, body]
      end
    end

    def header
      return unless @header
      tag :thead do
        tag :tr do
          @header.map do |item|
            tag(:th) { item }
          end.join "\n"
        end
      end
    end

    def body
      tag :tbody do
        @rows.map do |row_content|
          row row_content
        end.join "\n"
      end
    end

    def row row
      row_data, row_class =
        case row
        when Hash then
          [row.delete(:content), row]
        else
          [row, {}]
        end
      row_content =
        if row_data.is_a?(Array)
          row_data.map { |item| cell item }.join "\n"
        else
          row_data
        end
      tag :tr, row_content, row_class
    end

    def cell cell
      if cell.is_a? Hash
        content = cell.delete(:content).to_s
        tag :td, cell do
          content
        end
      else
        tag :td do
          String(cell)
        end
      end
    end

    def tag elem, content_or_opts={}, opts={}, &block
      if @div_table
        if content_or_opts.is_a? Hash
          @format.add_class content_or_opts, elem
        else
          @format.add_class opts, elem
        end
        elem = :div
      end
      @format.wrap_with elem, content_or_opts, opts, &block
    end
  end

  # @param [Array<Array,String>] content the content for the table. Accepts
  # strings or arrays for each row.
  # @param [Hash] opts
  # @option opts [String, Array] :header use first row of content as header or
  # value of this option if it is a string
  # @return [HTML] bootstrap table
  def table content, opts={}
    TableHelper.new(self, content, opts).render
  end
end
