# # Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  require_dependency 'exception_system'
  include AuthenticatedSystem
  include ExceptionSystem
  include LocationHelper
  helper :all
  include Recaptcha::Verify

  include ActionView::Helpers::SanitizeHelper

  before_filter :per_request_setup, :except=>[:render_fast_404]
 # after_filter :set_encoding
  # OPTIMIZE: render_fast_404 still isn't that fast (?18reqs/sec) 
  # can we turn sessions off for it and see if that helps?
  layout :wagn_layout, :except=>[:render_fast_404]
  
  attr_accessor :recaptcha_count
    
  BUILTIN_LAYOUTS = %w{ blank noside simple pre none }


  protected

  def per_request_setup
    ActiveSupport::Notifications.instrument 'wagn.per_request_setup', :message=>"" do
      request.format = :html if !params[:format]

      if Wagn::Conf[:multihost]
        MultihostMapping.map_from_request(request) or return render_fast_404(request.host)
      end

      # canonicalizing logic is wrong
      #canonicalize_domain
      #else
        Wagn::Conf[:host] = host = request.env['HTTP_HOST']
        Wagn::Conf[:base_url] = 'http://' + host
      #end
      
      ActiveSupport::Notifications.instrument 'wagn.renderer_load', :message=>"(in development)" do
        Wagn::Renderer.ajax_call=request.xhr?
      end
      Wagn::Renderer.current_slot = nil
    
      Wagn::Cache.re_initialize_for_new_request
    
      User.current_user = current_user || User[:anon]
    
      # RECAPTCHA HACKS
      Wagn::Conf[:controller] = self # this should not be conf, but more like wagn.env
      Wagn::Conf[:recaptcha_on] = !User.logged_in? &&     # this too 
        !!( Wagn::Conf[:recaptcha_public_key] && Wagn::Conf[:recaptcha_private_key] )
      @recaptcha_count = 0
    
      @action = params[:action]
    end
  end
  
  def canonicalize_domain
    if Rails.env=="production" and request.raw_host_with_port != Wagn::Conf[:host]
      query_string = request.query_string.empty? ? '' : "?#{request.query_string}"
      return redirect_to("http://#{Wagn::Conf[:host]}#{Wagn::Conf[:root_path]}#{request.path}#{query_string}")
    end
  end

  def wagn_layout
    layout = nil
    respond_to do |format|
      format.html {
        unless request.xhr?
          layout = 'application'
        end
      }
    end
    layout
  end

  def ajax?
    request.xhr?
  end

  # ------------------( permission filters ) -------
  def view_ok
    ActiveSupport::Notifications.instrument 'view_ok', :message=>"read #{@card.name}" do
      @card.ok?(:read) || render_denied('view')
    end
  end

  def update_ok
    @card.ok?(:update) || render_denied('edit')
  end



 #def create_ok
 #  @type = params[:type] || (params[:card] && params[:card][:type]) || 'Basic'
 #  @skip_slot_header = true
 #  #p "CREATE OK: #{@type}"
 #  t = Card.class_for(@type, :cardname) || Card::Basic
 #  t.create_ok? || render_denied('create')
 #end

  def remove_ok
    @card.ok!(:delete) || render_denied('delete')
  end



  # ----------( rendering methods ) -------------

  def wagn_redirect url
    if ajax?
      render :text => url, :status => 303
    else
      redirect_to url
    end 
  end

  def render_denied(action = '')
    @card.error_view = :denial
    @card.error_status = 403
    render_errors
  end

  def render_errors(card=nil, format='html')
    @card = card if card
    render_show( (@card.error_view || :errors), (@card.error_status || 422), format )
  end

end


