class FixWeirdExtensionsOnInvitationRequestTform < ActiveRecord::Migration
  def self.up   
    User.as(:admin) 
    ## in case there are broken keys
    while c = Card.find_by_key('')
      c.key = c.name.to_key
      c.save!
    end
    
    
    irt = Card["InvitationRequest+*tform"]
    if irt.extension_type == 'User' 
      irt.type = 'Basic'
      irt.extension_type='SoftTemplate';  
      irt.extension_id=nil
      irt.save!
    end
    
    c=Card["InvitationRequest"];
    c.name = "Account Request"
    c.confirm_rename = true
    c.save!


    
    add_index "cards", ["extension_type","extension_id"], 
      :name=>"cards_extension_type_id_index", :unique=>true
  end

  def self.down
  end
end
