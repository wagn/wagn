class Wagn::Renderer::Rss
  define_view(:show) do |args|
    
    xml = Builder::XmlMarkup.new
    xml.instruct! :xml, :version => "1.0"

    xml.rss :version => "2.0" do
      xml.channel do
        xml.title  System.site_title + " : " + card.name.gsub(/^\*/,'')
        xml.description ""
        xml.link card_url(card)
        begin
          cards = if card.typecode == 'Search'
            card.item_cards( :default_limit => 25, :_keyword=>params[:_keyword] )
          else
            [card]
          end
          view_changes = (card.name=='*recent')

          cards.each do |item|
            xml.item do
              xml.title item.name
              xml.description process_inclusion(item, :view=>(view_changes ? :change : :open_content))
              xml.pubDate item.revised_at.to_s(:rfc822)  #updated_at fails on virtual cards, because not all to_s's take args (just actual dates)
              xml.link card_url(item)
              xml.guid card_url(item)
            end
          end
        rescue Exception=>e
          xml.error "\n\nERROR rendering RSS: #{e.inspect}\n\n #{e.backtrace}"
        end
      end
    end
  end
  
  define_view(:titled) do |args|
    # content includes wrap  (<object>, etc.) , which breaks at least safari rss reader.
    content_tag( :h2, fancy_title(card.name) ) + self._render_open_content(args) { yield }
  end
  alias_view(:titled,      {}, :open)
  alias_view(:open_content,{}, :content)
  alias_view(:link,        {}, :closed)

  define_view(:change) do |args|
    #self.requested_view = 'content'
    render_view_action('change')
  end
  
end
