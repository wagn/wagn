class InvitationError < StandardError; end

class AccountController < ApplicationController
  layout 'application'
  before_filter :login_required, :only => [ :create, :invite, :update ] 
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
  
  def invitation_request
    # FIXME: this should be handled by card/new  (respond with different templates for different cardegories)
  end       
  
  def create_invitation_request
    # FIXME: this should be handled by card/create
#    if Card::InvitationRequest.create params
  end
  
  def login
    return unless request.post?
    self.current_user = User.authenticate(params[:login], params[:password])
    if current_user
      flash[:notice] = "Welcome to #{System.site_name}"
      #render :text=>"woohoo you logged in: #{current_user.inspect} <br> session: #{session.inspect}"
      return_to_rememberd_page
    else
      flash[:notice] = "Login Failed"
    end
  end

  def logout
    self.current_user = nil
    flash[:notice] = "You have been logged out."
    return_to_rememberd_page
  end
  
  def forgot_password
    return unless request.post?
    if @user = User.find_by_email(params[:email])
      @user.generate_password
      @user.save                       
      subject = "Password Reset"
      message = "You have been give a new temporary password.  " +
         "Please update your password once you've logged in. "
      Notifier.deliver_account_info(@user, subject, message)
      flash[:notice] = "A new temporary password has been set on your account and sent to your email address" 
      return_to_rememberd_page
    else
      flash[:notice] = "Could not find a user with that email address" 
    end  
  end
        
  def create
    return unless request.post? 
    # FIXME: not hardcode user cardtype??
    @card_name = params[:card][:name]
    @card = Card.find_by_name(@card_name) || Card::User.new( {
        :tag=>Tag.new( :datatype_key => 'User', :name=>@card_name )  
    }.merge(params[:card]) )
      
    if @card.class_name == 'InvitationRequest' 
      @user = @card.extension or raise "Blam.  InvitationRequest should've been connected to a user"    
      @card.type = 'User'
      @user.status='active'
      @user.invite_sender = ::User.current_user
    elsif @card.class_name=='User' and !@card.extension
      @user = User.new( params[:user].merge( :invite_sender_id=>current_user.id )) 
      @user.status='active'
    else
      @card.errors.add(:name, "has already been taken")
      raise ActiveRecord::RecordInvalid.new(@card)
    end
    @user.generate_password if @user.password.blank?

    User.transaction do 
      @card.extension = @user
      @user.save!
      @card.save!
            
      raise(Wagn::Oops, "Invitation Email subject is required") unless (params[:email] and params[:email][:subject])
      raise(Wagn::Oops, "Invitation Email message is required") unless (params[:email] and params[:email][:message])
      Notifier.deliver_account_info(@user, params[:email][:subject], params[:email][:message])
    end
    render :update do |page|
      page.wagn.messenger.note( "Successfully invited #{@card.name}.  Redirecting to #{previous_page}...")
      page.redirect_to url_for_page(previous_page)
    end
  end

=begin
    raise(Wagn::Oops, "Failed to connect card to user") unless (User.find_by_email(params[:user][:email]).card)
    raise(Wagn::Oops, "Failed to set datatype for user") unless (User.find_by_email(params[:user][:email]).card.tag.datatype_key=='User')
    raise(Wagn::Oops, "Invitation Email subject is required") unless (params[:email] and params[:email][:subject])
    raise(Wagn::Oops, "Invitation Email message is required") unless (params[:email] and params[:email][:message])
    Notifier.deliver_account_info(@user, params[:email][:subject], params[:email][:message])
    flash[:notice] = "User #{@card.name} has been created"
  rescue Exception=>e
    # if anything went wrong, don't leave any junk lying around
    # FIXME: this code has caused a lot of bug chasing-- would be cleaner and
    # more robust to have the card & extension creation together in a database transaction
    # at the model level.
    @user.destroy if @user && !@user.new_record?
    @card.destroy_without_permissions if @card && !@card.new_record?
    raise Wagn::Oops, e.message
  end
=end

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
end
