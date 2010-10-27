xml.instruct! :xml, :version => "1.0"

u = u.to_s(:rfc822) if u = card.updated_at
xml.outercard :link => card_url(card),
         :date => u,
         :name => card.name,
         :type => card.type,
         :revision => card.current_revision,
         :title => System.site_title + " : " + card.name.gsub(/^\*/,''),
         :key => card.key do
  slot = get_slot(card, "main_1", "view", {:format=>:xml})
  xml << slot.render(:content, :format=>:xml)
end
