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

  def reset_password account
    error = case
      when account.nil?      ;  "Unrecognized email."
      when !account.active?  ;  "That account is not active."
      end
    
    if error
      @card.errors.add :account, error
      false
    else
      account.send_confirmation_email(
        :subject => "Password Reset",
        :message => "Someone (we hope you) has asked to reset your password.  Click below to do so."
      )
    end
  end



end
