format :html do
  # @param [Array<Array,String>] content the content for the table. Accepts
  # strings or arrays for each row.
  # @param [Hash] opts
  # @option opts [String, Array] :header use first row of content as header or
  # value of this option if it is a string
  # @return [HTML] bootstrap table
  def table content, opts={}
    add_class opts, "table"
    if opts[:header]
      header = opts[:header].is_a?(Array) ? opts[:header] : content.shift
    end
    wrap_with :table, class: opts[:class] do
      [
        (table_header(header) if header),
        table_body(content)
      ]
    end
  end

  def table_header entries
    content_tag :thead do
      content_tag :tr do
        entries.map do |item|
          content_tag :th, item
        end.join "\n"
      end
    end
  end

  def table_body rows
    content_tag :tbody do
      rows.map do |row|
        table_row row
      end.join "\n"
    end
  end

  def table_cell cell
    if cell.is_a? Hash
      content_tag :td, cell.delete(:content).to_s.html_safe, cell
    else
      content_tag :td, cell.html_safe
    end
  end

  def table_row row
    row_data, row_class =
      case row
      when Hash then [row.delete(:content), row]
      else [row, nil]
      end
    row_content =
      if row_data.is_a?(Array)
        row_data.map { |item| table_cell item }.join "\n"
      else
        row_data
      end
    content_tag :tr, row_content.html_safe, row_class
  end
end
