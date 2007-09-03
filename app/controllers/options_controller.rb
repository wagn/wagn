class OptionsController < ApplicationController
  helper :wagn, :card 
  layout :ajax_or_not
  before_filter :load_card


  def update
    perms=params[:permissions]
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
    render :template=>'card/options' #fixme-perm  should have some sort of success notification...
  end
  
  def roles
    raise Wagn::Oops unless @card.class_name=='User'
   # @card = Card.find params[:id]
    @user = @card.extension
    @roles = Role.find :all, :conditions=>"codename not in ('auth','anon')"
  end
  
  def update_roles    
    @card = Card.find params[:id]
    @user = @card.extension
    @roles = Role.find :all, :conditions=>"codename not in ('auth','anon')"
    role_hash = params[:user_roles] || {}
    @user.roles = Role.find role_hash.keys
    if false  #FIXME- catch if anything breaks??
      render_update do |page|
        page << "$('#{params[:element]}').card().reset()"
      end
    else
      render :template=>'card/update'
    end
  end

end
