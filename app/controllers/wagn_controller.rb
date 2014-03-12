# -*- encoding : utf-8 -*-
class WagnController < ActionController::Base

  include Wagn::AuthenticatedSystem
  include Wagn::Location
  include Recaptcha::Verify

  before_filter :per_request_setup, :except=>[:fast_404]
  layout nil

  attr_reader :card

  def fast_404
    message = "<h1>404 Page Not Found</h1>"
    render :text=>message, :layout=>false, :status=>404
  end

  protected
  def per_request_setup
#    ActiveSupport::Notifications.instrument 'wagn.per_request_setup', :message=>"" do
    request.format = :html if !params[:format] #is this used??
    Wagn::Cache.renew
    Wagn::Env.reset :controller=>self
    Account.set_current_from_session #current_id = self.current_account_id || Card::AnonID
    Card::Format.ajax_call = ajax?             # move to Wagn::Env?
  end

  def ajax?
    request.xhr? || params[:simulate_xhr]
  end

  def html?
    [nil, 'html'].member?(params[:format])
  end

  # ----------( rendering methods ) -------------

  def wagn_redirect url
    url = wagn_url url #make sure we have absolute url
    if ajax?
      # lets client reset window location (not just receive redirected response)
      # formerly used 303 response, but that gave IE the fits
      render :json => {:redirect=> url}
    else
      redirect_to url
    end
  end

  def handle
    yield ? success : render_errors
  end
  
  
  def success
    redirect, new_params = !ajax?, {}

    target = case params[:success]
      when Hash
        new_params = params[:success]
        redirect ||= !!(new_params.delete :redirect)
        new_params.delete :id
      when /^REDIRECT:\s*(.+)/
        redirect=true
        $1
      when nil  ;  '_self'
      else      ;   params[:success]
      end
        
    target = case target
      when '*previous'     ;  previous_location #could do as *previous
      when /^(http|\/)/    ;  target
      when /^TEXT:\s*(.+)/ ;  $1
      else                 ;  Card.fetch target.to_name.to_absolute(card.cardname), :new=>{}
      end

    case
    when redirect
      target = page_path target.cardname, new_params if Card === target
      wagn_redirect target
    when String===target
      render :text => target
    else
      @card = target
      self.params = self.params.merge new_params #need tests.  insure we get slot, main...
      show
    end
  end


  def render_errors
    #fixme - should prioritize certain error classes
    code = nil
    card.errors.each do |key, msg|
      break if code = Card.error_codes[ key ]
    end
    view, status = code || [ :errors, 422]
    show view, status
  end
  


  def show view = nil, status = 200
    format = request.parameters[:format]
    format = :file if params[:explicit_file] or !Card::Format.registered.member? format #unknown format

    opts = ( params[:slot] || {} ).deep_symbolize_keys
    opts[:view] = view || params[:view]      

    formatter = Card::Format.new card, :controller=>self, :format=>format, :inclusion_opts=>opts[:items]
    result = formatter.show opts
    status = formatter.error_status || status
    
    if format==:file && status==200
      send_file *result
    elsif status == 302
      wagn_redirect result
    else
      args = { :text=>result, :status=>status }
      args[:content_type] = 'text/text' if format == :file
      render args
    end
  end
  

  rescue_from Exception do |exception|
    Rails.logger.info "exception = #{exception.class}: #{exception.message}"
    
    @card ||= Card.new
    
    view = case exception
      ## arguably the view and status should be defined in the error class;
      ## some are redundantly defined in view
      when Card::Oops, Card::Query
        card.errors.add :exception, exception.message 
        # Card::Oops error messages are visible to end users and are generally not treated as bugs.
        # Probably want to rename accordingly.
        :errors
      when Card::PermissionDenied, Wagn::PermissionDenied
        :denial
      when Wagn::NotFound, ActiveRecord::RecordNotFound, ActionController::MissingFile
        :not_found
      when Wagn::BadAddress
        :bad_address
      else #the following indicate a code problem and therefore require full logging
        Rails.logger.info exception.backtrace*"\n"
        notify_airbrake exception if Airbrake.configuration.api_key

        if ActiveRecord::RecordInvalid === exception
          :errors
        elsif Rails.logger.level == 0 # could also just check non-production mode...
          raise exception
        else
          :server_error
        end
      end

    show view
  end
  

  
end


