class AddSettings < ActiveRecord::Migration
  def self.up         
    User.as_admin do
      Card::Cardtype.create :name=>"Setting"
      Card::Setting.create :name=>'Thank You', :codename=>'invitation_request_landing', 
        :content=>"Your request has been received.  Please note that invitation requests are answered by volunteers," +
            "so it may take a bit longer an automated system, but you should get a response within a few days."
    end
  end
  

  def self.down
  end
end
