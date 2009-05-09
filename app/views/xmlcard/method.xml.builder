require 'ruby-debug'
xml.instruct! :xml, :version => "1.0"

#c = card
#debugger
#rev = c.current_revision
#cname = c.name
xml.card :link => card_url(card),
         :date => card.updated_at.to_s(:rfc822),
         :name => card.name,
         :type => card.type,
         :key => card.key do
         #:revision => rev.id,
         #:title => System.site_title + " : " + cname.gsub(/^\*/,'')
  slot = get_slot(card, "main_1", "view", {:format=>:xml, :transclusion_view_overrides => {
      :open => :xml,
      :content => :xml_content,
      :closed => :name,
      :open_missing => :name,
    }})
  xml << slot.render(:xml)
end
