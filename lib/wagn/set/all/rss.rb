# -*- encoding : utf-8 -*-
module Wagn
  module Set::All::Rss
    extend Set

    format :rss

    define_view :show do |args|
    #    render( args[:view] || :feed )
      render_feed
    end

    # FIXME: integrate this with common XML features when it is added
    define_view :feed do |args|
      xml = Builder::XmlMarkup.new
      xml.instruct! :xml, :version => "1.0"

      xml.rss :version => "2.0" do
        xml.channel do
          xml.title  Card.setting(:title) + " : " + card.name.gsub(/^\*/,'')
          xml.description ""
          xml.link wagn_url(card)
          begin
            cards = if card.type_id == Card::SearchTypeID
              card.item_cards( search_params.merge(:default_limit => 25) )
            else
              [card]
            end
            view_changes = (card.id==Card::RecentID)

            cards.each do |item|
              xml.item do
                xml.title item.name
                xml.description process_inclusion(item, :view=>(view_changes ? :change : :open_content))
                xml.pubDate item.revised_at.to_s(:rfc822)  #updated_at fails on virtual cards, because not all to_s's take args (just actual dates)
                xml.link wagn_url(item)
                xml.guid wagn_url(item)
              end
            end
          rescue Exception=>e
            xml.error "\n\nERROR rendering RSS: #{e.inspect}\n\n #{e.backtrace}"
          end
        end
      end
    end

    define_view :titled do |args|
      # content includes wrap  (<object>, etc.) , which breaks at least safari rss reader.
      content_tag( :h2, showname(args[:title]) ) + self._render_open_content(args) { yield }
    end
    alias_view(:titled,      {}, :open)
    alias_view(:open_content,{}, :content)
    alias_view(:link,        {}, :closed)

  end
end
