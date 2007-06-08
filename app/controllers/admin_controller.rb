class AdminController < ApplicationController
  layout 'application'
  
  
  def navigation
    @ok = System.ok_hash
    render :layout=>nil
  end
  
  def users
    @cards = Card.find_by_wql("cards with type= 'User'")
  end
  
  def roles
    @cards = Card.find_by_wql("cards with type= 'Role'")
  end
  
  def tasks
    @tasks = System.role_tasks
    @roles = Role.find_configurables
    @role_tasks = {}
    @roles.each { |r| @role_tasks[r.id] = r.task_list }
  end
  
  def save_tasks
    
    role_tasks = params[:role_task]
    Role.find( :all ).each  do |role|
      tasks = role_tasks[role.id.to_s] || {}
      role.tasks = tasks.keys.join(',')
      role.save
    end
  
    flash[:notice] = 'permissions saved'
    redirect_to :action=>'tasks'
  end
 
  
end
