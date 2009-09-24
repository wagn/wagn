
class GoogleMapsAddon    
  def self.geocode(address)
    '40.581144, -105.071947'
  end
end                     

class Card::Base
  after_save :update_geocode
  
  def update_geocode           
    if conf = CachedCard.get_real('*geocode')
      if self.junction? && conf.pointees.include?( self.name.tag_name )
        address = conf.pointees.map{|p| System.setting(self.name.trunk_name+"+#{p}")}.compact.join(' ')
        geocode = GoogleMapsAddon.geocode(address)
        Card.find_or_create(:name=>"#{self.name.trunk_name}+*geocode").update_attributes( :content => geocode )
      end
    end
  end
end
