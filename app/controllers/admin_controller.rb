class AdminController < ApplicationController
  layout 'application'
  
  
  def navigation
    @ok = System.ok_hash
    render :layout=>nil
  end
  
  def users
    @cards = Card.search(:type=>"User", :sort=>'alpha')
  end
  
  def roles
    @cards = Card.search(:type=>"Role", :sort=>'alpha')
  end
  
  def tasks
    System.ok!(:set_global_permissions)
    @tasks = System.role_tasks
    @roles = Role.find_configurables
    @role_tasks = {}
    @roles.each { |r| @role_tasks[r.id] = r.task_list }
  end
  
  def save_tasks
    System.ok!(:set_global_permissions)    
    role_tasks = params[:role_task]
    Role.find( :all ).each  do |role|
      tasks = role_tasks[role.id.to_s] || {}
      role.tasks = tasks.keys.join(',')
      role.save
    end
  
    flash[:notice] = 'permissions saved'
    redirect_to :action=>'tasks'
  end


  def setup
    ensure_new_system
    @user = User.find_by_login('admin')
  end
  
  
  def save_setup
    ensure_new_system
    @user = User.find_by_login('admin')
    if (@user.update_attributes( params[:user] ) and  
        @system = System.create(:name=>'wagn') and
        @system.save)
      #@user.activate( "Admin" )
      self.current_user = @user
      flash[:notice] = "Your administrative account has been activated. " + "Welcome!" 
      redirect_to previous_location
    else
      flash[:notice] = "Durn, setup went awry..."
      render :action=>'setup'
    end
  end
 
  private
    def ensure_new_system
      if System.count > 0
        flash[:notice] = "This WagN has already been setup"
        redirect_to '/'
      end
    end
  
end
