module Wagn::Set::Type::AccountRequest
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
  
end
