class AdminController < ApplicationController
  layout 'application'
  
  def setup
    raise(Wagn::Oops, "Already setup") unless User.no_logins? && !User[:first]
    if request.post?
      User.as :wagbot do
        @user, @card = User.create_with_card( params[:extension].merge({:login=>'first'}), params[:card] )
      end
      
      if @user.errors.empty?
        @user.roles = [Role[:admin]]
        self.current_user = @user
        User.cache.delete :no_logins
        flash[:notice] = "You're good to go!" 
        redirect_to '/'
      else
        flash[:notice] = "Durn, setup went awry..."
      end
    else
      @card = Card.new( params[:card] )
      @user = User.new( params[:user] )
    end
  end
  
  def tasks
    System.ok!(:set_global_permissions)
    @tasks = System.role_tasks
    @roles = Role.find_configurables.sort{|a,b| a.card.name <=> b.card.name }
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
  
=begin  

  
  def save_setup
    ensure_new_system
    @user = User.find_by_login('wagbot')
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

  def navigation
    @ok = System.ok_hash
    render :layout=>nil
  end

  def users
    #@cards = Card.search(:extension_type=>"User", :sort=>'alpha')
  end

  def roles
    @cards = Card.search(:extension_type=>"Role", :sort=>'alpha')
  end
=end  


  
end
