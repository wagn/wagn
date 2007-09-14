class OptionsController < ApplicationController
  helper :wagn, :card 
  layout :ajax_or_not
  before_filter :load_card


  def update
    if perms=params[:permissions] 
      @card.permissions=perms.keys.map do |task|
        party = 
          case perms[task]
          when ''; nil
          when 'personal'
            @card.personal_user
          else
            Role.find(perms[task])          
          end
        Permission.new :task=>task, :party=>party
      end
      @card.save
    end
    if ext = @card.extension and ext_params = params[:extension]
      ext.update_attributes!(ext_params)
      @extension = ext
    end
    @notice ||= "Got it!  Your changes have been saved."
    render :template=>'card/options' #fixme-perm  should have some sort of success notification...
  end
  
=begin
   def roles
    raise Wagn::Oops.new("roles method only applies to `user cards") unless @card.class_name=='User'
    @user = @card.extension
    @roles = Role.find :all, :conditions=>"codename not in ('auth','anon')"
  end
=end
  
  def update_roles    
    #FIXME-perm -- need better permissions checks for this!
    @extension = @card.extension
    role_hash = params[:user_roles] || {}
    @extension.roles = Role.find role_hash.keys
    @notice = "Done.  You've updated the roles."
    render :template=>'card/options'
  end

end
