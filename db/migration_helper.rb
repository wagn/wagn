module MigrationHelper
  module ClassMethods
    def add_cardtype( cardname, codename=nil ) 
      codename ||= cardname  
      User.as :admin do 
        if card = Card.find_by_name(cardname) and card.type=='Basic'
          card.type = 'Cardtype'
          #card.name = cardname
          card.save!
          card.extension.class_name=codename
          card.extension.save!
        else
          ct = Card::Cardtype.create! :name=>cardname, :codename=>codename
        end
      end
    end
  end
  
  def self.included(base)
    super
    base.extend(ClassMethods)
  end
end