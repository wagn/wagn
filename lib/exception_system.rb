module ExceptionSystem
  def rescue_action( exception )
    log_error(exception) if logger
    erase_results if performed?
    status = exception_status(exception)
    
    if exception.respond_to?(:card)
      render_card_errors(exception.card)
    elsif exception.respond_to?(:record)
      render_card_errors(exception.record)
    else
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
  end
   
  # these called by exception_notifier
  def render_404() 
    logger.error("render_404 invoked for request_uri=#{request.request_uri} and env=#{request.env.inspect}")
    render_exception(404); 
  end  
  
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

  def render_card_errors(card=nil)
    card ||= @card    
    stuff = %{Problem with card #{card.name}:<br>} + card.errors.full_messages.join(',')       
    # getNextElement() will crawl up nested slots until it finds one with a notice div
    if requesting_javascript?
      render :update do |page|
         page << %{notice = getNextElement(#{slot.selector},'notice');\n}
        page << %{notice.update('#{escape_javascript(stuff)}')}
      end
    elsif requesting_ajax?
      render :text=>stuff, :layout=>nil
    else
      render :text=>stuff, :layout=>'application'
    end
  end  
      
end
