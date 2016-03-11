# @param [Array<Array>] content the content for the table
# @param [Boolean] header use first row of content as header
# @return [HTML] bootstrap table
def table content, header=true
  wrap_with :table, class: 'table' do
    [
      (table_header(content.shift) if header),
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
          content_tag :td, item
        end.join "\n"
      end
    end.join "\n"
  end
end
