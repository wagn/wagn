event :update_geocode, :after=>:extend, :on=>:save do
  Auth.as_bot do
    if conf = Card['*geocode']
      if junction? && conf.item_names.include?( cardname.tag )
        address = conf.item_names.map do |p|
          c=Card.fetch( self.cardname.trunk_name.to_s+"+#{p}", :new=>{}) and c.content 
        end.select(&:present?) * ', '
        if (geocode = GoogleMapsAddon.geocode(address))
          c = Card.fetch "#{self.cardname.trunk_name.to_s}+*geocode", :new=>{ :type_id=>Card::PhraseID }
          c.save if c.new_card?
          c.update_attributes( :content => geocode )
        end
      end
    end
  end
end
