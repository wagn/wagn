class InvitationError < StandardError; end

class AccountController < ApplicationController
  layout :default_layout
  before_filter :login_required, :only => [ :invite, :update ] 
  #observer :card_observer, :tag_observer
  helper :wagn
                                                     
  def invite     
    if params[:name] && @card = Card.find_by_name(params[:name])
      @user = @card.extension
    else
      @card = Card.new
      @user = User.new
    end    
    @email={}
    @email[:subject] = System.setting( 'invitation email subject' )
    @email[:message] = System.setting( 'invitation email body' )
    @email[:message].substitute! :invitor => current_user.card.name + " <#{current_user.email}>" 
    @email[:message].gsub!(/Hello,/, "Hello #{@card.name},") if @card.name

  end
  
  def sign_up
    User.as :admin
  end       

  
  def login
    if false and using_open_id?
      open_id_authentication
    elsif params[:login]
      password_authentication(params[:login], params[:password])
    end
  end

  def logout
    self.current_user = nil
    flash[:notice] = "You have been logged out."
    redirect_to '/'  # previous_location here can cause infinite loop.
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
        
  def create
    return unless request.post? 
    # FIXME: not hardcode user cardtype??  
    @user = User.create_with_card( params )
    @card = @user.card
    
    render :update do |page|
      page.wagn.messenger.note( "Successfully invited #{@card.name}" )
      page.redirect_to previous_location
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
    else
      failed_login("Invalid email or password")
    end
  end

  def open_id_authentication
    warn "FAILED TPO FIND USER W/ IDENTEIY #{params[:openid_url]}"
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
  

  private  

    def successful_login
      flash[:notice] = "Welcome to #{System.site_name}"
      redirect_to previous_location
    end

    def failed_login(message)
      flash[:warning] = message
      render :action=>'login', :status=>403
      #warn   "Setting Flash = #{message}"
      #redirect_to(:action => 'login')
    end
        
end
