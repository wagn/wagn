require_dependency 'db/card_creator.rb'

class SystemCards < ActiveRecord::Migration
  class << self
    include CardCreator
  end
  
  def self.up
    create_user_card( 'Hooze Bot', 'hoozebot')
    create_user_card( 'Admin', 'admin' )
    
    create_cardtype_card 'Basic'
    create_cardtype_card 'Connection'
    create_cardtype_card 'User'
    create_cardtype_card 'Cardtype'
    create_cardtype_card 'Company'
  end

  def self.down
    
  end
end                         
