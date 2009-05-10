xml.instruct! :xml, :version => "1.0"

xml.card :link => card_url(card),
         :date => card.updated_at.to_s(:rfc822),
         :name => card.name,
         :type => card.type,
         :revision => card.card.current_revision.id,
         :title => System.site_title + " : " + card.name.gsub(/^\*/,''),
         :key => card.key do
  slot = get_slot(card, "main_1", "view", {:format=>:xml, :transclusion_view_overrides => {
      :open => :xml,
      :content => :xml,
      :closed => :name,
      :open_missing => :name,
    }})
  xml << slot.render(:xml)
end
