module ExceptionSystem
  def rescue_action( exception )
    log_error(exception) if logger
    erase_results if performed?
    status = exception_status(exception)
    if status==500
      if consider_all_requests_local || local_request?
        rescue_action_locally(exception)
      else
        rescue_action_in_public(exception)
      end
    else        
      render_exception(status)
    end
  end
   
  # these called by exception_notifier
  def render_404()  render_exception(404); end
  def render_500()  render_exception(500); end

  def render_exception(status)
    render :template => "/application/#{status}", :status => status, :layout=>ajax_or_not
  end  
  
  def exception_status(exception)
    @exception = exception
    case exception                                                        
      when Wagn::Oops, Wagn::RecursiveTransclude, ActiveRecord::RecordInvalid
        422
      when Wagn::PermissionDenied, Card::PermissionDenied
        403
      when Wagn::NotFound, ActiveRecord::RecordNotFound, ActionController::UnknownController, ActionController::UnknownAction  
        404
      else 
        500 
      end
  end

=begin
    respond_to do |type|
      type.html { render :partial => "/application/e#{status}", :status => status, :layout=>ajax_or_not, :locals=>{} }
      type.js do
        render :update do |page| 
          page.wagn.messenger.alert :partial=>"/application/e#{status}", :status=>status 
        end
      end
      type.all  { render :nothing => true, :status => status }
    end
=end    

=begin  
  def render_denied( text )
    @oops = text
    respond_to do |format|
      format.html { 
        return render( :file=>RAILS_ROOT + '/public/403.html', :layout=>'application', :status=>403 )
        #render :inline=>%{Sorry, you don't have permissions to #{@oops} <%= javascript_tag "new Effect.Highlight('alerts')" %>}, :status=>"500 Error" 
      }
      format.js {
        render :update do |page|
          page.wagn.messenger.alert @oops 
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
=end

      
end
