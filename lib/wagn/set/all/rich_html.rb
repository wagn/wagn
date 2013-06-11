module Wagn
  class Renderer::Html
    
    def build_menu_items array
      
      array.map do |h|
        add_li_tag = true
        h = h.clone if Hash===h
        if !h[:if] or @menu_vars[ h[:if] ]
          h[:text] = h[:text] % @menu_vars if h[:text]
          link = case
            when h[:plain]
              "<a>#{h[:plain]}</a>"
            when h[:link]
              menu_subs h[:link]
            when h[:page]
              next unless h[:page] = menu_subs( h[:page] )
              link_to_page (raw("#{h[:text] || h[:page]} &crarr;")), h[:page]
            when h[:list]
              items = []
              h[:list].each do |k1,v1| # piecenames, {pages=>itmes}
                items = menu_subs(k1).map do |item_val| #[names].each do |name|
                  menu_item = v1.clone
                  menu_item.each do |k2, v2| # | :page, :item|
                    menu_item[k2] = item_val[v2] if item_val.has_key?(v2)
                  end
                  menu_item
                end
              end
              add_li_tag = false
              build_menu_items items
            else
              if h[:related]
                h[:related] = if Symbol === h[:related]
                  h[:text] ||= h[:related].to_s.gsub '_', ' '
                  { :name => '+' + Card.fetch( h[:related], :skip_modules=>true ).name }
                else
                  h2 = h[:related].clone
                  h2[:name] = menu_subs h2[:name]
                  h2
                end
                h[:view] = :related
                h[:path_opts] ||= {}
                h[:path_opts].merge! :related=>h[:related]
              end                
                
              if h[:view]
                link_to_view (h[:text] || h[:view]), h[:view], :class=>'slotter', :path_opts=>h[:path_opts]
              else
                raise "bad menu item"
              end
            end
          sub = h[:sub] && "\n<ul>\n#{build_menu_items h[:sub]}\n</ul>\n"
          add_li_tag ? "<li>#{link} #{sub}</li>" : link
        end
      end.flatten.compact * "\n"
    end
    
    def menu_subs key
      Symbol===key ? @menu_vars[key] : key
    end
    
    def watching_type_cards
      %{<div class="faint">(following)</div>} #yuck
    end

    def watch_link text, toggle, title, extra={}
      link_to "#{text}", path(:action=>:watch, :toggle=>toggle), 
        {:class=>"watch-toggle watch-toggle-#{toggle} slotter", :title=>title, :remote=>true, :method=>'post'}.merge(extra)
    end
  end  
end