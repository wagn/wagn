module Wagn::Set::Type::InvitationRequest
  def before_destroy
    block_user
  end

  private
 
  def block_user
    account = User.where(:card_id=>self.id).first
    if account
      account.update_attributes :status=>'blocked'
    end
  end
  
=begin
  def destroy_extension
    #do nothing - we want to keep these accounts around to know they're blocked.
  end
=end

end
