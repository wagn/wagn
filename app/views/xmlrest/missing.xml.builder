xml.instruct! :xml, :version => "1.0"

if card
xml.card :name => card.name,
         :type => card.type,
         :title => System.site_title + " : " + card.name.gsub(/^\*/,''),
         :status => 'missing'
else
 "<no card/>"
end
