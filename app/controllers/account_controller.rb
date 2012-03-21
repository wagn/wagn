# -*- encoding : utf-8 -*-
class InvitationError < StandardError; end

class AccountController < ApplicationController
  before_filter :login_required, :only => [ :invite, :update ]
  helper :wagn

  def signup
    raise(Wagn::PermissionDenied, "You have to sign out before signing up for a new Account") if logged_in?  #ENGLISH
    raise(Wagn::PermissionDenied, "Sorry, no Signup allowed") unless Card.new(:typecode=>'InvitationRequest').ok? :create #ENGLISH

    user_args = (params[:user]||{}).merge(:status=>'pending').symbolize_keys
    @user = User.new( user_args ) #does not validate password
    card_args = (params[:card]||{}).merge(:typecode=>'InvitationRequest')
    @card = Card.new( card_args )

    return unless request.post?

    return render_user_errors if @user.errors.any?
    @user, @card = User.create_with_card( user_args, card_args )
    return render_user_errors if @user.errors.any?

    if User.ok?(:create_accounts)       #complete the signup now
      email_args = { :message => Card.setting('*signup+*message') || "Thanks for signing up to #{Card.setting('*title')}!",  #ENGLISH
                     :subject => Card.setting('*signup+*subject') || "Account info for #{Card.setting('*title')}!" }  #ENGLISH
      @user.accept(email_args)
      return wagn_redirect Card.path_setting(Card.setting('*signup+*thanks'))
    else
      User.as :wagbot do
        Mailer.signup_alert(@card).deliver if Card.setting('*request+*to')
      end
      return wagn_redirect Card.path_setting(Card.setting('*request+*thanks'))
    end
  end




  def accept
    raise(Wagn::Oops, "I don't understand whom to accept") unless params[:card]
    @card = Card[params[:card][:key]] or raise(Wagn::NotFound, "Can't find this Account Request")  #ENGLISH
    @user = @card.extension or raise(Wagn::Oops, "This card doesn't have an account to approve")  #ENGLISH
    User.ok?(:create_accounts) or raise(Wagn::PermissionDenied, "You need permission to create accounts")  #ENGLISH

    if request.post?
      @user.accept(params[:email])
      if @user.errors.empty? #SUCCESS
        redirect_to Card.path_setting(Card.setting('*invite+*thanks'))
        return
      end
    end
    render :action=>'invite'
  end

  def invite
    User.ok?(:create_accounts) or raise(Wagn::PermissionDenied, "You need permission to create")  #ENGLISH
    @user, @card = request.post? ?
      User.create_with_card( params[:user], params[:card] ) :
      [User.new, Card.new()]
    if request.post? and @user.errors.empty?
      @user.send_account_info(params[:email])
      redirect_to Card.path_setting(Card.setting('*invite+*thanks'))
    end
  end


  def signin
    if params[:login]
      password_authentication(params[:login], params[:password])
    end
  end

  def signout
    self.current_user = nil
    flash[:notice] = "Successfully signed out" #ENGLISH
    redirect_to Card.path_setting('/')  # previous_location here can cause infinite loop.  ##  Really?  Shouldn't.  -efm
  end

  def forgot_password
    return unless request.post?
    @user = User.find_by_email(params[:email].downcase)
    if @user.nil?
      flash[:notice] = "Unrecognized email."   #ENGLISH
      render :action=>'signin', :status=>404
    elsif !@user.active?
      flash[:notice] = "That account is not active."  #ENGLISH
      render :action=>'signin', :status=>403
    else
      @user.generate_password
      @user.save!
      subject = "Password Reset"  #ENGLISH
      message = "You have been given a new temporary password.  " +  #ENGLISH
         "Please update your password once you've signed in. "
      Mailer.account_info(@user, subject, message).deliver
      flash[:notice] = "Check your email for your new temporary password"  #ENGLISH
      redirect_to previous_location
    end
  end

  protected
  
  def render_user_errors
    @user.errors.each do |field, err|
      @card.errors.add field, err
    end
    render_errors
  end
  
  def password_authentication(login, password)
    if self.current_user = User.authenticate(params[:login], params[:password])
      flash[:notice] = "Successfully signed in"  #ENGLISH
      redirect_to previous_location
    else
      u = User.find_by_email(params[:login].strip.downcase)
      failed_login(
        case
        when u.nil?     ; "Unrecognized email."
        when u.blocked? ; "Sorry, that account is blocked."
        else            ; "Wrong password"
        end
      )
    end
  end

  def failed_login(message)
    flash[:notice] = "Oops: #{message}"
    render :action=>'signin', :status=>403
  end

end
