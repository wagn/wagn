module ExceptionSystem
  def oops( text )
    raise Wagn::Oops, text
  end
  
  def rescue_action( exception )
    log_error(exception) if logger
    erase_results if performed?
    
    case exception
      when Wagn::Oops; render_oops( exception.message )
      when Wagn::PermissionDenied; render_denied( exception.message )
      when Wagn::RecursiveTransclude; render_oops( exception.message )
      when ActiveRecord::RecordInvalid; render_oops( exception.message )
      else 
        if consider_all_requests_local || local_request?
          rescue_action_locally(exception)
        else
          rescue_action_in_public(exception)
        end
    end
  end
  
  def render_404
    #respond_to do |type|
    #  type.html { render :file => "#{RAILS_ROOT}/public/404.html", :status => "404 Not Found" }
    #  type.all  { render :nothing => true, :status => "404 Not Found" }
    #end
    render :template=> '/application/404', :status => '404 Not Found'
  end

  def render_500
    respond_to do |type|
      type.html { render :template => '/application/500', :status => "500 Error", :layout=>'application' }
      type.all  { render :nothing => true, :status => "500 Error" }
    end
  end
  
  def render_denied( text )
    @oops = text
    respond_to do |format|
      format.html { 
        return render( :file=>RAILS_ROOT + '/public/403.html', :layout=>'application', :status=>403 )
        #render :inline=>%{Sorry, you don't have permissions to #{@oops} <%= javascript_tag "new Effect.Highlight('alerts')" %>}, :status=>"500 Error" 
      }
      format.js {
        render :update do |page|
          page.wagn.messenger.alert "Sorry, you don't have permissions to #{@oops}" 
        end
      }
    end
  end

  def render_oops( text )
    @oops = text
    respond_to do |format|
      format.html { 
        render :inline=>%{Oops!! #{@oops} <%= javascript_tag "new Effect.Highlight('alerts', {startcolor:'#ffff00', endcolor:'#ffffaa', restorecolor:'#ffffaa', duration:1})" %>}, :status=>"500 Error" 
#        FIXME.  duplication.  can't this use Wagn.Messenger somehow?
      }
      format.js {
        render :update do |page|
          page.wagn.messenger.alert "Oops!! #{@oops}" 
          page.wagn.card.dehighlight_all() # FIXME -- this is a bit brute force...
        end
      }
    end
  end
      
end
