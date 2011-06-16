module Card::InvitationRequest
  attr_accessor :account  ## is this used??

  def self.append_features(base)
    base.send :before_destroy, :block_user
  end
    
  private
 
  def block_user
    if extension
      extension.update_attributes :status=>'blocked'
    end
  end
  
  def destroy_extension
    #do nothing - we want to keep these accounts around to know they're blocked.
  end
  
end
