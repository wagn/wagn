# -*- encoding : utf-8 -*-
#
class InvitationError < StandardError; end

class AccountController < CardController

  before_filter :login_required, :only => [ :invite, :update ]
  helper :wagn

  #ENGLISH many messages throughout this file
  def signup
    #FIXME - don't raise; handle it!
    raise(Wagn::Oops, "You have to sign out before signing up for a new Account") if logged_in?
    
    card_params = ( params[:card] || {} ).symbolize_keys.merge :type_id=>Card::AccountRequestID
    user_params = ( params[:user] || {} ).symbolize_keys.merge :status=>'pending'
    
    @card = Card.new card_params
    #FIXME - don't raise; handle it!
    raise(Wagn::PermissionDenied, "Sorry, no Signup allowed") unless @card.ok? :create

    if !request.post? #signup form
      @user = User.new user_params
    else
      @user, @card = User.create_with_card user_params, card_params
      if @user.errors.any?
        user_errors 
      else
        if @card.ok?(:create, :new=>{}, :trait=>:account)      # automated approval
          email_args = { :message => Card.setting('*signup+*message') || "Thanks for signing up to #{Card.setting('*title')}!",
                         :subject => Card.setting('*signup+*subject') || "Account info for #{Card.setting('*title')}!" }
          @user.accept @card, email_args
          #Rails.logger.warn "signup #{@user.inspect}, #{@user.errors.full_messages*', '}, #{@card.inspect} #{@card.errors.full_messages*', '},"
          redirect_cardname = '*signup+*thanks'
        else                                            # requires further approval
          Account.as_bot do
            Mailer.signup_alert(@card).deliver if Card.setting '*request+*to'
          end
          #Rails.logger.warn "signup with/app #{@user}, #{@card}"
          redirect_cardname = '*request+*thanks'
        end
        wagn_redirect Card.setting( redirect_cardname )
      end
    end
  end

  def accept
    card_key=params[:card][:key]
    #warn "accept #{card_key.inspect}, #{Card[card_key]}, #{params.inspect}"
    raise(Wagn::Oops, "I don't understand whom to accept") unless params[:card]
    @card = Card[card_key] or raise(Wagn::NotFound, "Can't find this Account Request")
    #warn "accept #{Account.authorized_id}, #{@card.inspect}"
    @user = @card.account or raise(Wagn::Oops, "This card doesn't have an account to approve")
    #warn "accept #{@user.inspect}"
    @card.ok?(:create) or raise(Wagn::PermissionDenied, "You need permission to create accounts")

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
    cok=Card.new(:name=>'dummy+*account').ok?(:create) or raise(Wagn::PermissionDenied, "You need permission to create")
    #warn "post invite #{cok}, #{request.post?}, #{params.inspect}"
    @user, @card = request.post? ?
      User.create_with_card( params[:user], params[:card] ) :
      [User.new, Card.new()]
    #warn "invite U:#{@user.inspect} C:#{@card.inspect}"
    if request.post? and @user.errors.empty?
      @user.send_account_info(params[:email])
      redirect_to Card.path_setting(Card.setting('*invite+*thanks'))
    end
  end


  def signin
    #warn Rails.logger.info("signin #{params[:login]}")
    if params[:login]
      password_authentication params[:login], params[:password]
    end
  end

  def signout
    self.session_card_id = nil
    flash[:notice] = "Successfully signed out"
    redirect_to Card.path_setting('/')  # previous_location here can cause infinite loop.  ##  Really?  Shouldn't.  -efm
  end

  def forgot_password
    return unless request.post? and email = params[:email].downcase
    @user = User.find_by_email(email)
    if @user.nil?
      flash[:notice] = "Unrecognized email."
      render :action=>'signin', :status=>404
    elsif !@user.active?
      flash[:notice] = "That account is not active."
      render :action=>'signin', :status=>403
    else
      @user.generate_password
      @user.save!
      subject = "Password Reset"
      message = "You have been given a new temporary password.  " +
         "Please update your password once you've signed in. "
      Mailer.account_info(@user, subject, message).deliver
      flash[:notice] = "Check your email for your new temporary password"
      redirect_to previous_location
    end
  end

  protected

  def user_errors
    @user.errors.each do |field, err|
      @card.errors.add field, err unless @card.errors[field].any?
      # needed to prevent duplicates because User adds them in the other direction in user.rb
    end
    render_errors
  end

  def password_authentication(login, password)
    if self.session_card_id = User.authenticate( params[:login], params[:password] )
      flash[:notice] = "Successfully signed in"
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
