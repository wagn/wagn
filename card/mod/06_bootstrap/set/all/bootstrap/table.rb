format :html do
  # @param [Array<Array,String>] content the content for the table. Accepts
  # strings or arrays for each row.
  # @param [Hash] opts
  # @option opts [String, Array] :header use first row of content as header or
  # value of this option if it is a string
  # @return [HTML] bootstrap table
  def table content, opts={}
    add_class opts, 'table'
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

  def table_row row
    row_content =
      if row.is_a? Array
        row.map do |item|
          if item.is_a? Hash
            content_tag :td, item.delete(:content), item
          else
            content_tag :td, item
          end
        end.join "\n"
      else
        row
      end

    content_tag :tr, row_content.html_safe
  end
end
