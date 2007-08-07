class UserRenderer < Renderer::Base
  
  def extra_options
    if System.ok? :manage_permissions 
      controller.render :partial=>'options/option', :locals=>{
        :name=>'roles',
        :label=>'Roles', 
        :field=>link_to_remote( "User Roles", 
          :url=>{ :controller=>'options', :action=>'roles', :id=>params[:id], 
                  :params=>{:element=>params[:element]} 
                }, :update=>"#{params[:element]}-options-workspace" 
        ), 
        :help=>''
      }
    end
  end
  
=begin  
  def extra_connection_tabs
    link_to_connector_update( 
      image_tag( 'editedby_icon.png', :title=> "cards edited by \"#{@card.name}\""),
      'connection-menu', 'query', 'revised_by'
    )
  end
=end
 
end



