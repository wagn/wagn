# -*- encoding : utf-8 -*-
class AccountController < WagnController

#  def signout
#    self.current_account_id = nil
#    redirect_to Card.path_setting('/')  # previous_location here can cause infinite loop.  ##  Really?  Shouldn't.  -efm
#  end

  def forgot_password
    @card = Card.new
    if email = params[:email]
      handle { reset_password Account[ email.downcase ] }
    else
      show :forgot_password 
    end
  end

  protected

  def reset_password accounted
    error = case
      when !accounted                  ;  "Unrecognized email."
      when !accounted.account.active?  ;  "That account is not active."
      end
    
    if error
      @card.errors.add :account, error
      false
    else
      accounted.account.confirmation_email(
        :subject => "Password Reset",
        :message => "Someone (we hope you) has asked to reset your password.  Click below to do so."
      ).deliver
    end
  end



end
