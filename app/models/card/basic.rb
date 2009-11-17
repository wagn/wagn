module Card
  class Basic < Base
    def self.permission_dependent_cardtypes
      Card::Cardtype.find(:all).reject { |c| c.type_templator? }
    end

    def post_render(content)
      #warn "CALLED POST RENDER: #{content}"
      table_of_contents(content) || content
    end

    def table_of_contents(content)
      min = self.setting('table of contents').to_i
      return unless min and min > 0
      
      toc = []  
      current_depth = 1
      content.gsub!( /<(h1)>(.*?)<\/h1>|<(h2)>(.*?)<\/h2>/i ) do
        tag, value = $~[1] ? $~[1,2] : $~[3,2]
        next if value.strip.empty?
        value = ActionView::Base.new.strip_tags(value)
        item = { :value => value, :uri => URI.escape(value) }
        case tag
        when 'h1'
          item[:depth] = current_depth = 1          
          toc << item
        when 'h2'
          toc << []  if current_depth == 1
          item[:depth] = current_depth = 2
          toc.last << item
        end
        %{<a name="#{item[:uri]}"></a>} + $MATCH
      end

      if toc.flatten.length >= min
        content.replace %{ <div class="table-of-contents"> <h5>Table of Contents</h5> } +
        make_table_of_contents_list(toc) + '</div>'+ content
      end
    end
    
    private

    def make_table_of_contents_list(items)
      list = items.collect do |i|
        Array === i ? make_table_of_contents_list(i) : %{<li><a href="##{i[:uri]}"> #{i[:value]}</a></li>}
      end.join("\n")
      "<ol>" + list + "</ol>"
    end

  end
end
