xml.instruct! :xml, :version => "1.0"

xml.card :date => card.updated_at.to_s(:rfc822),
         :link => card_url(card),
         :name => card.name,
         :type => card.type,
         :key => card.key,
         :revision => card.current_revision.id,
         :title => System.site_title + " : " + @card.name.gsub(/^\*/,'') do
  slot = get_slot(card, "main_1", "view", :transclusion_view_overrides => {
      :open => :xml,
      :content => :xml_content,
      :closed => :name,
      :open_missing => :name,
    })
  xml << slot.render_xml( :xml_expanded )
end
