# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include LocationHelper
  include Recaptcha::Verify
  include ActionView::Helpers::SanitizeHelper

  helper :all
  before_filter :per_request_setup, :except=>[:fast_404]
  layout :wagn_layout, :except=>[:fast_404]
  
  attr_accessor :recaptcha_count

  def fast_404(host=nil)
    message = "<h1>404 Page Not Found</h1>"
    message += "Unknown host: #{host}" if host
    render :text=>message, :layout=>false, :status=>404
  end

  def bad_address
    raise Wagn::BadAddress, "could not find a route to match this address"
  end

  protected

  def per_request_setup
#    ActiveSupport::Notifications.instrument 'wagn.per_request_setup', :message=>"" do
      request.format = :html if !params[:format]

      # these should not be Wagn::Conf, but more like wagn.env
      Wagn::Conf[:host] = host = request.env['HTTP_HOST']
      Wagn::Conf[:base_url] = 'http://' + host
      Wagn::Conf[:main_name] = nil
      Wagn::Conf[:controller] = self 

      Wagn::Renderer.ajax_call = ajax?
      Wagn::Renderer.current_slot = nil
    
      Wagn::Cache.re_initialize_for_new_request
    
      User.current_user = current_user || User[:anon]
    
      # RECAPTCHA HACKS
      Wagn::Conf[:recaptcha_on] = !User.logged_in? &&     # this too 
        !!( Wagn::Conf[:recaptcha_public_key] && Wagn::Conf[:recaptcha_private_key] )
      @recaptcha_count = 0
    
      @action = params[:action]
#    end
  end
  
  def canonicalize_domain
    if Rails.env=="production" and request.raw_host_with_port != Wagn::Conf[:host]
      query_string = request.query_string.empty? ? '' : "?#{request.query_string}"
      return redirect_to("http://#{Wagn::Conf[:host]}#{request.path}#{query_string}")
    end
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

  # ------------------( permission filters ) -------
  def view_ok()    @card.ok?(:read)   || render_denied('view')    end
  def update_ok()  @card.ok?(:update) || render_denied('edit')    end
  def remove_ok()  @card.ok!(:delete) || render_denied('delete')  end

 #def create_ok
 #  @type = params[:type] || (params[:card] && params[:card][:type]) || 'Basic'
 #  @skip_slot_header = true
 #  #p "CREATE OK: #{@type}"
 #  t = Card.class_for(@type, :cardname) || Card::Basic
 #  t.create_ok? || render_denied('create')
 #end


  # ----------( rendering methods ) -------------

  def wagn_redirect url
    if ajax?
      render :text => url, :status => 303
    else
      redirect_to url
    end 
  end

  def render_denied(action = nil)
    params[:action] = action if action
    @card.error_view = :denial
    @card.error_status = 403
    render_errors
  end

  def render_errors options={}
    @card ||= Card.new
    view   = options[:view]   || (@card && @card.error_view  ) || :errors
    status = options[:status] || (@card && @card.error_status) || 422
    render_show view, status
  end

  def render_show view = nil, status = 200
    ext = request.parameters[:format]
    known = FORMATS.split('|').member? ext 
    
    if !known && @card && @card.error_view
      ext, known = 'txt', true
      # render simple text for errors on unknown formats; without this, file/image permissions checks are meaningless
    end

    case
    when known                # renderers can handle it
      r = Wagn::Renderer.new @card, :format=>ext, :controller=>self
      render :text=>r.render_show( :view => view ), :status=>status
    when render_show_file     # send_file can handle it
    else                      # dunno how to handle it
      render :text=>"unknown format: #{extension}", :status=>404
    end
  end
  
  def render_show_file
    return fast_404 if !@card
    @card.selected_rev_id = (@rev_id || @card.current_revision_id).to_i
  
    format = @card.attachment_format(params[:format])
    return fast_404 if !format

    if ![format, 'file'].member?( params[:format] )
      return redirect_to( request.fullpath.sub( /\.#{params[:format]}\b/, '.' + format ) ) #@card.attach.url(style) ) 
    end

    style = @card.attachment_style( @card.typecode, params[:size] || @style )
    return fast_404 if !style

    send_file @card.attach.path(style), 
      :type => @card.attach_content_type,
      :filename =>  "#{@card.cardname.to_url_key}#{style.blank? ? '' : '-'}#{style}.#{format}",
      :x_sendfile => true,
      :disposition => (params[:format]=='file' ? 'attachment' : 'inline' )
  end
  
  
  rescue_from Exception do |exception|
    Rails.logger.info "exception = #{exception.class}: #{exception.message}"
        
    view, status = case exception
    when Wagn::NotFound, ActiveRecord::RecordNotFound
      [ :not_found, 404 ]                                                 
    when Wagn::PermissionDenied, Card::PermissionDenied
      [ :denial, 403]
    when Wagn::BadAddress, ActionController::UnknownController, AbstractController::ActionNotFound  
      [ :bad_address, 404 ]
    else
      notify_airbrake exception if Airbrake.configuration.api_key
      
      if [Wagn::Oops, ActiveRecord::RecordInvalid].member?( exception.class ) && @card && @card.errors.any?
        [ :errors, 422]
      else
        Rails.logger.info "\n\nController exception: #{exception.message}"
        Rails.logger.debug exception.backtrace*"\n"
        Rails.logger.level == 0 ? raise( exception ) : [ :server_error, 500 ]
      end
    end
    
    render_errors :view=>view, :status=>status
  end
     
end


