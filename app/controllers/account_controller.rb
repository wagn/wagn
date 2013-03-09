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
    account_params = ( params[:account] || {} ).symbolize_keys.merge :status=>'pending'
    
    @card = Card.new card_params
    #FIXME - don't raise; handle it!
    raise(Wagn::PermissionDenied, "Sorry, no Signup allowed") unless @card.ok? :create

    if !request.post? #signup form
      @account = User.new account_params
    else
      @account, @card = User.create_with_card account_params, card_params
      if @card.errors.any?
        render_errors
      else
        if @card.ok?(:create, :new=>{}, :trait=>:account)      # automated approval
          email_args = { :message => Card.setting('*signup+*message') || "Thanks for signing up to #{Card.setting('*title')}!",
                         :subject => Card.setting('*signup+*subject') || "Account info for #{Card.setting('*title')}!" }
          @account.accept @card, email_args
          redirect_cardname = '*signup+*thanks'
        else                                            # requires further approval
          Account.as_bot do
            Mailer.signup_alert(@card).deliver if Card.setting '*request+*to'
          end
          #Rails.logger.warn "signup with/app #{@account}, #{@card}"
          redirect_cardname = '*request+*thanks'
        end
        wagn_redirect Card.setting( redirect_cardname )
      end
    end
  end

  def accept
    card_key=params[:card][:key]
    raise(Wagn::Oops, "I don't understand whom to accept") unless params[:card]
    @card = Card[card_key] or raise(Wagn::NotFound, "Can't find this Account Request")
    @account = @card.account or raise(Wagn::Oops, "This card doesn't have an account to approve")
    @card.ok?(:create) or raise(Wagn::PermissionDenied, "You need permission to create accounts")

    if request.post?
      @account.accept(@card, params[:email])
      if @card.errors.empty? #SUCCESS
        redirect_to Card.path_setting(Card.setting('*invite+*thanks'))
        return
      end
    end
    render :action=>'invite'
  end

  def invite
    User.create_ok? or raise(Wagn::PermissionDenied, "You need permission to create")
    @account, @card = request.post? ?
      User.create_with_card( params[:account], params[:card] ) :
      [User.new, Card.new()]
    if request.post? and @card.errors.empty?
      @account.send_account_info(params[:email])
      redirect_to Card.path_setting(Card.setting('*invite+*thanks'))
    end
  end


  def signin
    if params[:login]
      password_authentication params[:login], params[:password]
    end
  end

  def signout
    self.current_account_id = nil
    flash[:notice] = "Successfully signed out"
    redirect_to Card.path_setting('/')  # previous_location here can cause infinite loop.  ##  Really?  Shouldn't.  -efm
  end

  def forgot_password
    if request.post? and email = params[:email]
      @account = User.find_by_email email.downcase
      case
      when @account.nil?
        flash[:notice] = "Unrecognized email."
        render :action=>'signin', :status=>404
      when !@account.active?
        flash[:notice] = "That account is not active."
        render :action=>'signin', :status=>403
      else
        @account.generate_password
        @account.save!
        subject = "Password Reset"
        message = "You have been given a new temporary password.  " +
           "Please update your password once you've signed in. "
        @account.send_account_info(:subject => subject, :message => message)
        flash[:notice] = "Check your email for your new temporary password"
        redirect_to previous_location
      end
    else
      raise Wagn::BadAddress
    end
  end

  protected

  def password_authentication(login, password)
    if self.current_account_id = User.authenticate( params[:login], params[:password] )
      flash[:notice] = "Successfully signed in"
      #warn Rails.logger.info("to prev #{previous_location}")
      redirect_to previous_location
    else
      usr=User[ params[:login].strip.downcase ]
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
