class OptionsController < ApplicationController
  helper :wagn, :card 
  layout :default_layout
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
      @card.save!
    end
    if params[:save_roles]
      System.ok! :assign_user_roles
      role_hash = params[:user_roles] || {}
      @card.extension.roles = Role.find role_hash.keys
    end
=begin    
    if params[:card] and ext_type = params[:card][:extension_type]
      @card.extension_type = ext_type
      @card.save!
    end
=end
    if ext = @card.extension and ext_params = params[:extension]
      #fixme.  should have something like @card.ok? :account that uses extension checks...
      ext.update_attributes!(ext_params)
      @extension = ext
    end
    @notice ||= "Got it!  Your changes have been saved."
    render_update_slot render_to_string(:template=>'card/options')
  end
  

end
