class AdminController < ApplicationController
  layout 'application'

  def setup
    raise(Wagn::Oops, "Already setup") unless User.no_logins? && !User[:first]
    if request.post?
      Card::User  # wtf - trigger loading of Card::User, otherwise it tries to use U
      User.as :wagbot do
        @user, @card = User.create_with_card( params[:extension].merge({:login=>'first'}), params[:card] )
        set_default_request_recipient
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
      @card = Card.new( params[:card] || {} ) #should prolly skip defaults
      @user = User.new( params[:user] || {} )
    end
  end

  def tasks
    raise Wagn::PermissionDenied.new('Only Administrators can view tasks') unless System.always_ok?
    @tasks = System.role_tasks
    @roles = Role.find_configurables.sort{|a,b| a.card.name <=> b.card.name }
    @role_tasks = {}
    @roles.each { |r| @role_tasks[r.id] = r.task_list }
  end

  def save_tasks
    raise Wagn::PermissionDenied.new('Only Administrators can change task permissions') unless System.always_ok?
    role_tasks = params[:role_task] || {}
    Role.find( :all ).each  do |role|
      tasks = role_tasks[role.id.to_s] || {}
      role.tasks = tasks.keys.join(',')
      role.save
    end

    flash[:notice] = 'permissions saved'
    redirect_to :action=>'tasks'
  end
  
  def show_cache
    key = params[:id].to_key
    @cache_card = Card.fetch(key)
    @db_card = Card.find_by_key(key)
  end
  
  def clear_cache
    response = 
      if System.always_ok?
        Card.cache.reset
        'Cache cleared'
      else
        "You don't have permission to clear the cache"
      end
    render :text =>response, :layout=> true  
  end

  private
  
  def set_default_request_recipient
    to_card = Card.fetch_or_new('*request+*to')
    to_card.content=params[:extension][:email]
    to_card.save
  end

end
