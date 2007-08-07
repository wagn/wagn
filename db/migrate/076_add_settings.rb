
class AddSettings < ActiveRecord::Migration
  class << self
    include CardCreator
  end
  
  def self.up         
    User.as(:admin) do
      create_cardtype_card 'Setting'
      create_setting_card 'Thank You', 'invitation_request_landing', 
        "Your request has been received.  Please note that invitation requests are answered by volunteers," +
            "so it may take a bit longer an automated system, but you should get a response within a few days."
    end
  end
  

  def self.down
  end
end
