xml.instruct! :xml, :version => "1.0"

if card
  u = u.to_s(:rfc822) if u = card.updated_at
  rid = rid.id if rid = card.current_revision
  xml.outercard :link => card_url(card),
           :date => u,
           :name => card.name,
           :type => card.type,
           :revision => rid,
           :title => System.site_title + " : " + card.name.gsub(/^\*/,''),
           :key => card.key do
    slot = get_slot(card, "main_1", "view", {:format=>:xml, :transclusion_view_overrides => {
        :open => :xml,
        :content => :xml,
        :closed => :name,
        :open_missing => :name,
      }})
    xml << slot.render(:content, :format=>:xml)
  end
else
  "No card?"+foobar.name
end
