# -*- encoding : utf-8 -*-
class AccountController < WagnController

  def signin
    @card = Card.new
    if params[:login]
      handle { password_authentication params[:login], params[:password] }
    else
      show :signin_and_forgot_password
    end
  end

  def signout
    self.current_account_id = nil
    flash[:notice] = "Successfully signed out"
    redirect_to Card.path_setting('/')  # previous_location here can cause infinite loop.  ##  Really?  Shouldn't.  -efm
  end

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
      account.send_account_info(
        :subject => "Password Reset",
        :message => "You have been given a new temporary password. Please update your password once you've signed in."
      )
    end
  end



end
