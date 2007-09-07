module MigrationHelper
  module ClassMethods
    def add_cardtype( cardname, codename=nil ) 
      codename ||= cardname 
      auth = Role.find_by_codename 'auth' 
      default_permissions = [:this,:should,:not,:go_on].map {|p| Permission.create(:task=>p, :party=>auth)}
      User.as :admin do 
        if card = Card.find_by_name(cardname) and card.type=='Basic'
          card.type = 'Cardtype'
          #card.name = cardname
          card.permissions =  default_permissions
          card.save!
          card.extension.class_name=codename
          card.extension.permissions =  default_permissions
          card.extension.save!
        else
          ct = Card::Cardtype.create! :name=>cardname, :codename=>codename, :permissions=> default_permissions
        end
      end
    end
    
  end
  
  def self.included(base)
    super
    base.extend(ClassMethods)
  end
end