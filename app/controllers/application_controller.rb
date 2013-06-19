# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base

  include Wagn::Exceptions

  include Wagn::AuthenticatedSystem
  include LocationHelper
  include Recaptcha::Verify
  include ActionView::Helpers::SanitizeHelper


  helper :all
  before_filter :per_request_setup, :except=>[:fast_404]
  layout :wagn_layout, :except=>[:fast_404]

  attr_reader :card
  attr_accessor :recaptcha_count

  def fast_404
    message = "<h1>404 Page Not Found</h1>"
    render :text=>message, :layout=>false, :status=>404
  end

  protected
  def per_request_setup
#    ActiveSupport::Notifications.instrument 'wagn.per_request_setup', :message=>"" do
      request.format = :html if !params[:format] #is this used??

      # these should not be Wagn::Conf, but more like WagnEnv
      Wagn::Conf[:host] = host = request.env['HTTP_HOST']
      Wagn::Conf[:base_url] = request.protocol + host
      Wagn::Conf[:main_name] = nil
      Wagn::Conf[:controller] = self

      Wagn::Cache.renew

      Wagn::Renderer.ajax_call = ajax?
      Wagn::Renderer.current_slot = nil

      #warn "set curent_user (app-cont) #{self.current_account_id}, U.cu:#{Account.current_id}"
      Account.current_id = self.current_account_id || Card::AnonID
      #warn "set curent_user a #{current_account_id}, U.cu:#{Account.current_id}"

      # RECAPTCHA HACKS
      Wagn::Conf[:recaptcha_on] = !Account.logged_in? &&     # this too
        !!( Wagn::Conf[:recaptcha_public_key] && Wagn::Conf[:recaptcha_private_key] )
      @recaptcha_count = 0
  end

  def wagn_layout
    layout = nil
    respond_to do |format|
      format.html { layout = 'application' unless ajax? }
    end
    layout
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
      render :text => url, :status => 303
    else
      redirect_to url
    end
  end


  def render_errors
    view   = card.error_view   || :errors
    status = card.error_status || 422
    show view, status
  end


  def show view = nil, status = 200
    format = request.parameters[:format]
    format = :file if !FORMATS.split('|').member? format #unknown format

    opts = params[:slot] || {}
    opts[:view] = view || params[:view]      

    renderer = Wagn::Renderer.new card, :controller=>self, :format=>format
    result = renderer.render_show opts
    status = renderer.error_status || status
    
    if format==:file && status==200
      send_file *result
    else
      args = { :text=>result, :status=>status }
      args[:content_type] = 'text/text' if format == :file
      render args
    end
  end
  


  rescue_from Exception do |exception|
    Rails.logger.info "exception = #{exception.class}: #{exception.message}"
    
    @card ||= Card.new
    
    view, status = case exception
      ## arguably the view and status should be defined in the error class;
      ## some are redundantly defined in view
      when Wagn::PermissionDenied, Card::PermissionDenied
        [ :denial, 403]
      when Wagn::NotFound, ActiveRecord::RecordNotFound, ActionController::MissingFile
        [ :not_found, 404 ]        
      when Wagn::BadAddress
        [ :bad_address, 404 ]
      when Wagn::Oops
        card.errors.add :exception, exception.message 
        # Wagn:Oops error messages are visible to end users and are generally not treated as bugs.
        # Probably want to rename accordingly.
        [ :errors, 422]
      else #the following indicate a code problem and therefore require full logging
        Rails.logger.info exception.backtrace*"\n"
        notify_airbrake exception if Airbrake.configuration.api_key

        if ActiveRecord::RecordInvalid === exception
          [ :errors, 422]
        elsif Wagn::Conf[:migration] or Rails.logger.level == 0 # could also just check non-production mode...
          raise exception
        else
          [ :server_error, 500 ]
        end
      end

    show view, status
  end
end


