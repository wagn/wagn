class InvitationError < StandardError; end

class AccountController < ApplicationController
  layout 'application'
  before_filter :login_required, :only => [ :invite, :create, :update ] 
  #observer :card_observer, :tag_observer
  helper :wagn
                                                     
  def invite
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
      UserNotifier.deliver_account_info(@user, subject, message)
      flash[:notice] = "A new temporary password has been set on your account and sent to your email address" 
      return_to_rememberd_page
    else
      flash[:notice] = "Could not find a user with that email address" 
    end  
  end
        
  def create
    return unless request.post? 
    # FIXME: not hardcode user cardtype??
    @tag = Tag.new( :datatype_key => 'User', :name=>params[:card][:name] )
    @card = Card::User.new( {:tag=>@tag}.merge(params[:card]))
    @user = User.new( params[:user].merge( :invited_by=>current_user.id ))  
    if @user.password.blank?
      @user.generate_password
    end
    @user.save!
    @card.extension = @user
    @card.save!    
    raise(Wagn::Oops, "Failed to connect card to user") unless (User.find_by_email(params[:user][:email]).card)
    raise(Wagn::Oops, "Failed to set datatype for user") unless (User.find_by_email(params[:user][:email]).card.tag.datatype_key=='User')
    raise(Wagn::Oops, "Invitation Email subject is required") unless (params[:email] and params[:email][:subject])
    raise(Wagn::Oops, "Invitation Email message is required") unless (params[:email] and params[:email][:message])
    UserNotifier.deliver_account_info(@user, params[:email][:subject], params[:email][:message])
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
