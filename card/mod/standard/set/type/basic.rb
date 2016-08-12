format :html do
  view :open_content do |args|
    content = _render_core args
    table_of_contents(content) || content
  end

  def table_of_contents content
    return if @mode == :closed || !content.present?
    min = card.rule(:table_of_contents).to_i
    # warn "table_of #{name}, #{min}"
    return unless min && min > 0

    toc = []
    dep = 1
    content.gsub!(/<(h\d)>(.*?)<\/h\d>/i) do |match|
      if $LAST_MATCH_INFO
        tag, value = $LAST_MATCH_INFO[1, 2]
        value = ActionView::Base.new.strip_tags(value).strip
        next if value.empty?
        item = { value: value, uri: URI.escape(value) }
        case tag.downcase
        when "h1"
          item[:depth] = dep = 1; toc << item
        when "h2"
          toc << []  if dep == 1
          item[:depth] = dep = 2; toc.last << item
        end
        %(<a name="#{item[:uri]}"></a>#{match})
      end
    end

    if toc.flatten.length >= min
      content.replace %( <div class="table-of-contents"> <h5>Table of Contents</h5> ) +
                      make_table_of_contents_list(toc) + "</div>" + content
    end
  end

  def make_table_of_contents_list items
    list = items.map do |i|
      Array === i ? make_table_of_contents_list(i) : %(<li><a href="##{i[:uri]}"> #{i[:value]}</a></li>)
    end.join("\n")
    "<ol>" + list + "</ol>"
  end
end
