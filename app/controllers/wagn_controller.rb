class WagnController < ApplicationController
  def new
    ensure_new_system
    @user = User.find_by_login('admin')
  end
  
  def show
    @wagn = System.find(1)
  end
  
  def create
    ensure_new_system
    @user = User.find_by_login('admin')
    if (@user.update_attributes( params[:user] ) and  
        @system = System.create(:name=>'wagn') and
        @system.save)
      #@user.activate( "Admin" )
      self.current_user = @user
      flash[:notice] = "Your administrative account has been activated. " + "Welcome!" 
      return_to_rememberd_page
    else
      render :action=>'new'
    end
  end
  
  private
    def ensure_new_system
      if System.count > 0
        flash[:notice] = "This WagN has already been setup"
        redirect_to :action=>:show, :id=>1
      end
    end
    
end
