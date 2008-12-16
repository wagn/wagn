class FixWeirdExtensionsOnInvitationRequestTform < ActiveRecord::Migration
  def self.up   
    User.as(:admin) 
    ## in case there are broken keys
    while c = Card.find_by_key('')
      c.key = c.name.to_key
      c.save!
    end
    
    
    if irt = Card["InvitationRequest+*tform"]
      if irt.extension_type == 'User' 
        irt.type = 'Basic'
        irt.save!
        irt=Card["InvitationRequest+*tform"] 
        irt.extension_type='SoftTemplate';  
        irt.extension_id=nil
        irt.save!
      end
    end
    
    if c=Card["InvitationRequest"];
      c.name = "Account Request"
      c.confirm_rename = true
      c.save!
    end

    
    begin
      add_index "cards", ["extension_type","extension_id"], 
        :name=>"cards_extension_type_id_index", :unique=>true
    rescue
    end
  end

  def self.down
  end
end
