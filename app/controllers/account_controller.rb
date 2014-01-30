# -*- encoding : utf-8 -*-
class AccountController < WagnController

  def signin
    @card = Card.new
    if params[:login]
      password_authentication params[:login], params[:password]
    else
      show :signin
    end
  end

  def signout
    self.current_account_id = nil
    flash[:notice] = "Successfully signed out"
    redirect_to Card.path_setting('/')  # previous_location here can cause infinite loop.  ##  Really?  Shouldn't.  -efm
  end

  def forgot_password
    @card = Card.new
    if request.post? and email = params[:email]
      @account = Account[ email.downcase ]
      case
      when @account.nil?
        flash[:notice] = "Unrecognized email."
        show :signin, 404
      when !@account.active?
        flash[:notice] = "That account is not active."
        show :signin, 403
      else
        @account.send_account_info(
          :subject => "Password Reset",
          :message => "You have been given a new temporary password. Please update your password once you've signed in."
        )
        flash[:notice] = "Check your email for your new temporary password"
        redirect_to previous_location
      end
    else
      show :forgot_password 
    end
  end

  protected

  def password_authentication(login, password)
    if self.current_account_id = Account.authenticate( params[:login], params[:password] )
      flash[:notice] = "Successfully signed in"
      #warn Rails.logger.info("to prev #{previous_location}")
      redirect_to previous_location
    else
      usr=Account[ params[:login].strip.downcase ]
      failed_login(
        case
        when usr.nil?     ; "Unrecognized email."
        when usr.blocked? ; "Sorry, that account is blocked."
        else              ; "Wrong password"
        end
      )
    end
  end

  def failed_login(message)
    flash[:notice] = "Oops: #{message}"
    show :signin, 403
  end

end
