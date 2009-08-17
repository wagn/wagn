class OptionsController < ApplicationController
  helper :wagn, :card 
  before_filter :load_card

  def update
    if perms=params[:permissions] 
      @card.permissions=perms.keys.map do |task|
        party = 
          case perms[task]
            when ''        ; nil
            when 'personal'; @card.personal_user
            else           ; Role.find(perms[task])          
          end
        Permission.new :task=>task, :party=>party
      end
      @card.save!
    end
    
    if params[:save_roles]
      System.ok! :assign_user_roles
      role_hash = params[:user_roles] || {}
      @card.extension.roles = Role.find role_hash.keys
    end

    if ext = @card.extension and ext_params = params[:extension]
      #fixme.  should have something like @card.ok? :account that uses extension checks...
      ext.update_attributes!(ext_params)
      @extension = ext
    end
    @notice ||= "Got it!  Your changes have been saved."
    render_update_slot render_to_string(:template=>'card/options')
  end
  
  def new_account
    System.ok!(:create_accounts) && @card.ok?(:edit)
  end
  
  def create_account
    System.ok!(:create_accounts) && @card.ok?(:edit)
    email_args = { :subject => "Your new #{System.site_title} account.", 
                   :message => "Welcome!  You now have an account on #{System.site_title}." }
    @user, @card = User.create_with_card(params[:user],@card, email_args)
    raise ActiveRecord::RecordInvalid.new(@user) if !@user.errors.empty?
    @extension = User.new(:email=>@user.email)
    @notice ||= "Done.  A password has been sent to that email."
    render_update_slot render_to_string(:template=>'card/options')        
  end


end
