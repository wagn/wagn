class InvitationError < StandardError; end

class AccountController < ApplicationController
  before_filter :login_required, :only => [ :invite, :update ] 
  helper :wagn
  
  def signup
    raise(Wagn::Oops, "You have to sign out before signing up for a new Account") if logged_in?
    raise(Wagn::PermissionDenied, "Sorry, no Signup allowed") unless Card::InvitationRequest.create_ok?
    card_args = (params[:card]||{}).merge({:type=>'InvitationRequest'})

    #fail "params.inspect: #{params.inspect}" if request.post?
    @user, @card = request.post? ?
      User.create_with_card( params[:user], card_args ) :
      [User.new, Card.new( card_args )]

    if request.post? 
      captcha_ok = captcha_required? ? verify_captcha(:model=>@user) : true
      if captcha_ok and @user.errors.empty?

      
        User.as :wagbot  do ## in case user doesn't have permission for included cardtypes.  For now letting signup proceed even if there are errors on multi-update
          @card.multi_update(params[:cards]) if params[:multi_edit] and params[:cards]  
        end
      
      
        if System.ok?(:create_accounts)       #complete the signup now
          email_args = { :message => System.setting('*signup+*message') || "Thanks for signing up to #{System.site_title}!",
                         :subject => System.setting('*signup+*subject') || "Account info for #{System.site_title}!" }
          @user.accept(email_args)
          redirect_to (System.setting('*signup+*thanks') || '/')
        else
          Mailer.deliver_signup_alert(@card) if System.setting('*request+*to')
          redirect_to (System.setting('*request+*thanks') || '/')
        end
      end
    end
  end
  
  def thanks(card_name)
    thanks = System.setting(card_name)
    thanks
  end
  
  def accept
    @card = Card[params[:card][:key]] or raise(Wagn::NotFound, "Can't find this Account Request")
    @user = @card.extension or raise(Wagn::Oops, "This card doesn't have an account to approve")
    System.ok?(:create_accounts) or raise(Wagn::PermissionDenied, "You need permission to create accounts")
    
    if request.post?
      @user.accept(params[:email])
      if @user.errors.empty? #SUCCESS
        redirect_to (System.setting('*invite+*thanks') || '/')
        return
      end
    end
    render :action=>'invite'
  end
  
  def invite
    System.ok?(:create_accounts) or raise(Wagn::PermissionDenied, "You need permission to create")
    
    @user, @card = request.post? ? 
      User.create_with_card( params[:user], params[:card] ) :
      [User.new, Card.new]
    if request.post? and @user.errors.empty?
      @user.send_account_info(params[:email])
      redirect_to (System.setting('*invite+*thanks') || '/')
    end
  end
  

  def signin
    #if false and using_open_id?
    #  open_id_authentication
    #els
    if params[:login]
      password_authentication(params[:login], params[:password])
    end
  end

  def logout
    self.current_user = nil
    flash[:notice] = "You have been logged out."
    redirect_to '/'  # previous_location here can cause infinite loop.  ##  Really?  Shouldn't.  -efm
  end
  
  def forgot_password
    return unless request.post?
    if @user = User.find_by_email(params[:email])
      @user.generate_password
      @user.save!                       
      subject = "Password Reset"
      message = "You have been given a new temporary password.  " +
         "Please update your password once you've logged in. "
      Mailer.deliver_account_info(@user, subject, message)
      flash[:notice] = "A new temporary password has been set on your account and sent to your email address" 
      redirect_to previous_location
    else
      flash[:notice] = "Could not find a user with that email address" 
      render :action=>'signin', :status=>403
    end  
  end
        


  def update
    load_card
    @user = @card.extension or raise("extension gotta be a user")        
    element_id = params[:element]           
    context = edit_user_context(@card)
    #TODO: need to check context for security
    
    if @user.update_attributes params[:user]
      render :update do |page|
        page.wagn.card.find("#{element_id}").continue_save()
      end 
    else  
      error_message = render_to_string :inline=>'<%= error_messages_for :user %>'
      render :update do |page|
        page.wagn.messenger.note "Update user failed" + error_message
        
      end
    end    
  end  
    
  protected
  def password_authentication(login, password)
    if self.current_user = User.authenticate(params[:login], params[:password])
      successful_login
    elsif u = User.find_by_email(params[:login].strip)
      if u.blocked
        failed_login("Sorry, this account is currently blocked.")
      else
        failed_login("Wrong password for that email")
      end
    else
      failed_login("We don't recognize that email")
    end
  end

=begin
  def open_id_authentication
    warn "FAILED TPO FIND USER W/ IDENTITY #{params[:openid_url]}"
    unless params[:openid_url] &&   user = User.find_by_identity_url(params[:openid_url])
      failed_login("Sorry, no user by that identity URL exists (#{params[:openid_url] })" +
        "You need to have an account on Wagn already and set the OpenId in your options")
      return
    end
       
    warn "GOING TO SERVER"
    authenticate_with_open_id do |result, identity_url|
      if result.successful?
        self.current_user = user
        successful_login
      else
        failed_login result.message
      end
    end
  end   
  
  def authenticate_with_open_id(identity_url = params[:openid_url], options = {}, &block) #:doc:
    if params[:open_id_complete].nil?
      begin_open_id_authentication(normalize_url(identity_url), options, &block)
    else
      complete_open_id_authentication(&block)
    end
  end
=end  

  private  

    def successful_login
      flash[:notice] = "Welcome to #{System.site_title}"
      redirect_to previous_location
    end

    def failed_login(message)
      flash[:warning] = message
      render :action=>'signin', :status=>403
    end
        
end
