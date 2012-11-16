# -*- encoding : utf-8 -*-
class InvitationError < StandardError; end

class AccountController < ApplicationController
  before_filter :login_required, :only => [ :invite, :update ]
  helper :wagn

  def signup
    raise(Wagn::Oops, "You have to sign out before signing up for a new Account") if logged_in?  #ENGLISH
    c=Card.new(:type_id=>Card::AccountRequestID)
    #warn Rails.logger.warn("signup ok? #{c.inspect}, #{c.ok? :create}")
    raise(Wagn::PermissionDenied, "Sorry, no Signup allowed") unless c.ok? :create #ENGLISH
    #raise(Wagn::PermissionDenied, "Sorry, no Signup allowed") unless Card.new(:typecode=>:account_request).ok? :create #ENGLISH

    user_args = (params[:user]||{}).merge(:status=>'pending').symbolize_keys
    @user = User.new( user_args ) #does not validate password
    card_args = (params[:card]||{}).merge(:type_id=>Card::AccountRequestID)

    unless request.post?
      @card = Card.new( card_args )
      return
    end

    return user_errors if @user.errors.any?
    @user, @card = User.create_with_card( user_args, card_args )
    return user_errors if @user.errors.any?

    if @card.trait_card(:account).ok?(:create)       #complete the signup now
      email_args = { :message => Card.setting('*signup+*message') || "Thanks for signing up to #{Card.setting('*title')}!",  #ENGLISH
                     :subject => Card.setting('*signup+*subject') || "Account info for #{Card.setting('*title')}!" }  #ENGLISH
      @user.accept(@card, email_args)
      return wagn_redirect Card.path_setting(Card.setting('*signup+*thanks'))
    else
      Session.as_bot do
        Mailer.signup_alert(@card).deliver if Card.setting('*request+*to')
      end
      return wagn_redirect Card.path_setting(Card.setting('*request+*thanks'))
    end
  end

  def accept
    card_key=params[:card][:key]
    #warn "accept #{card_key.inspect}, #{Card[card_key]}, #{params.inspect}"
    raise(Wagn::Oops, "I don't understand whom to accept") unless params[:card]
    @card = Card[card_key] or raise(Wagn::NotFound, "Can't find this Account Request")  #ENGLISH
    #warn "accept #{Session.user_id}, #{@card.inspect}"
    @user = @card.to_user or raise(Wagn::Oops, "This card doesn't have an account to approve")  #ENGLISH
    #warn "accept #{@user.inspect}"
    @card.ok?(:create) or raise(Wagn::PermissionDenied, "You need permission to create accounts")  #ENGLISH

    if request.post?
      #warn "accept #{@card.inspect}, #{@user.inspect}"
      @user.accept(@card, params[:email])
      if @user.errors.empty? #SUCCESS
        redirect_to Card.path_setting(Card.setting('*invite+*thanks'))
        return
      end
    end
    render :action=>'invite'
  end

  def invite
    #warn "invite: ok? #{Card.new(:name=>'dummy+*account').ok?(:create)}"
    cok=Card.new(:name=>'dummy+*account').ok?(:create) or raise(Wagn::PermissionDenied, "You need permission to create")  #ENGLISH
    #warn "post invite #{cok}, #{request.post?}, #{params.inspect}"
    @user, @card = request.post? ?
      User.create_with_card( params[:user], params[:card] ) :
      [User.new, Card.new()]
    #warn "invite U:#{@user.inspect} C:#{@card.inspect}"
    if request.post? and @user.errors.empty?
      @user.send_account_info(params[:email])
      redirect_to Card.path_setting(Card.setting('*invite+*thanks'))
    end
    #warn "invite errors #{@user.errors} C:#{@card.errors}"
    #unless @user.errors.empty?
    #  @user.errors.each do |k,e| warn "user error #{k}, #{e}" end
    #end
  end


  def signin
    #warn Rails.logger.info("signin #{params[:login]}")
    if params[:login]
      password_authentication params[:login], params[:password]
    end
  end

  def signout
    self.session_user = nil
    flash[:notice] = "Successfully signed out" #ENGLISH
    redirect_to Card.path_setting('/')  # previous_location here can cause infinite loop.  ##  Really?  Shouldn't.  -efm
  end

  def forgot_password
    return unless request.post? and email = params[:email].downcase
    @user = User.find_by_email(email)
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

  def user_errors
    @user.errors.each do |field, err|
      @card.errors.add field, err unless @card.errors[field].any?
      # needed to prevent duplicates because User adds them in the other direction in user.rb
    end
    errors
  end

  def password_authentication(login, password)
    if self.session_user = User.authenticate( params[:login], params[:password] )
      flash[:notice] = "Successfully signed in"  #ENGLISH
      #warn Rails.logger.info("to prev #{previous_location}")
      redirect_to previous_location
    else
      usr=User.where(:email=>params[:login].strip.downcase).first
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
    render :action=>'signin', :status=>403
  end

end
