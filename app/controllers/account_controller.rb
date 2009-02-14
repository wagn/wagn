class InvitationError < StandardError; end

class AccountController < ApplicationController
  layout :default_layout
  before_filter :login_required, :only => [ :invite, :update ] 
  #observer :card_observer, :tag_observer
  helper :wagn

  def signup
    raise(Wagn::Oops, "You have to sign out before signing up for a new Account") if logged_in?
    card_args = (params[:card]||{}).merge({:type=>'InvitationRequest'})
    @user, @card = request.post? ?
      User.create_with_card( params[:user], card_args ) :
      User.new, Card.new( card_args )
    if request.post? and @card.errors.empty?
      @card.multi_update(params[:cards]) if params[:multi_edit] and params[:cards]  
      ## fixme.  For now letting signup proceed even if there are errors on multi-update
      flash[:notice] = System.setting('*signup+*thanks')
      if User.create_ok? 
        @user.accept
        @user.send_account_info(signup_email_info)
        redirect_to url_for_page @card.name
      else
        Notifier.deliver_signup_alert(record) if System.setting('*invite+*to')
        redirect_to previous_location
      end
    end
    render :action=>'signup'
  end
  
  def signup_email_info
    { :message => System.setting('*signup+*message') || "Thanks for signing up to #{System.site_title}!",
      :subject => System.setting('*signup+*subject') || "Account info for #{System.site_title}!" }
  end
  
  def accept
    @card = Card[params[:card][:key]] or raise(Wagn::NotFound, "Can't find this Account Request")
    @user = @card.extension or raise(Wagn::Oops, "This card doesn't have an account to approve")
    User.create_ok? or raise(Wagn::PermissionDenied, "You need permission to accept Account Requests")
    
    if request.post?
      @user.accept
      if @card.errors.empty? #SUCCESS
        @user.send_account_info(params[:email])
        #flash[:notice] = System.setting('*accept+*thanks')
        redirect_to url_for_page(Card::InvitationRequest.new.cardtype.name)
        return
      end
    end
    render :action=>'invite'
  end
  
  def invite
    User.create_ok? or raise(Wagn::PermissionDenied, "You need permission to Invite New Users")
    @user, @card = request.post? ? 
      User.create_with_card( params[:user], params[:card] ) :
      [User.new, Card.new]
    if request.post? and @card.errors.empty?
      @user.send_account_info(params[:email])
      flash[:notice] = System.setting('*invite+*thanks')
      redirect_to previous_location
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
      message = "You have been give a new temporary password.  " +
         "Please update your password once you've logged in. "
      Notifier.deliver_account_info(@user, subject, message)
      flash[:notice] = "A new temporary password has been set on your account and sent to your email address" 
      redirect_to previous_location
    else
      flash[:notice] = "Could not find a user with that email address" 
      render :action=>'login', :status=>403
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
    elsif User.find_by_email(params[:login])
      failed_login("Wrong password for that email")
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
