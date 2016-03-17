format :html do
  # @param [Array<Array>] content the content for the table
  # @param [Boolean] header use first row of content as header
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
      content_tag :tr do
        row.map do |item|
          if item.is_a? Hash
            content_tag :td, item.delete(:content), item
          else
            content_tag :td, item
          end
        end.join "\n"
      end
    end.join "\n"
  end
  end
end

