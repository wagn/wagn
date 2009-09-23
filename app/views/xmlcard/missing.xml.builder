xml.instruct! :xml, :version => "1.0"

xml.card :name => card.name,
         :type => card.type,
         :title => System.site_title + " : " + card.name.gsub(/^\*/,''),
         :key => card.key,
         :status => 'missing'
