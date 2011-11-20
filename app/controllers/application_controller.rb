# # Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  require_dependency 'exception_system'
  include AuthenticatedSystem
  include ExceptionSystem
  include LocationHelper
  helper :all

  include ActionView::Helpers::SanitizeHelper

  before_filter :per_request_setup, :except=>[:render_fast_404]
 # after_filter :set_encoding
  # OPTIMIZE: render_fast_404 still isn't that fast (?18reqs/sec) 
  # can we turn sessions off for it and see if that helps?
  layout :wagn_layout, :except=>[:render_fast_404]
  
    
  BUILTIN_LAYOUTS = %w{ blank noside simple pre none }


  protected

  def per_request_setup
    request.format = :html if !params[:format]
    
    Wagn::Renderer.ajax_call=request.xhr?
    if System.multihost
      MultihostMapping.map_from_request(request) or return render_fast_404(request.host)
    end
    Wagn::Cache.re_initialize_for_new_request
    canonicalize_domain
    
    User.current_user = current_user || User[:anon]

    @action = params[:action]

    Wagn::Renderer.current_slot = nil
    System.request = request
  end
  
  def canonicalize_domain
    if Rails.env=="production" and request.raw_host_with_port != System.host
      query_string = request.query_string.empty? ? '' : "?#{request.query_string}"
      return redirect_to("http://#{System.host}#{System.root_path}#{request.path}#{query_string}")
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

  # ------------------( permission filters ) -------
  def view_ok
    @card.ok?(:read) || render_denied('view')
  end

  def update_ok
    @card.ok?(:update) || render_denied('edit')
  end

  def ajax?
    request.xhr?
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


  # --------------( card loading filters ) ----------
  def load_card!
    load_card
    case
    when !@card || @card.name.nil? || @card.name.empty?  #no card or no name -- bogus request, deserves error
      raise Wagn::NotFound, "We don't know what card you're looking for."
    when @card.known? # default case
      @card
    when params[:view] =~ /rule|missing/
      # FIXME this is a hack so that you can view load rules that don't exist.  need better approach 
      # (but this is not tested; please don't delete without adding a test) 
      @card
    when ajax? || ![nil, 'html'].member?(params[:format])  #missing card, nonstandard request
      ##  I think what SHOULD happen here is that we render the missing view and let the Renderer decide what happens.
      raise Wagn::NotFound, "We can't find a card named #{@card.name}"  
    when @card.ok?(:create)  # missing card, user can create
      params[:card]={:name=>@card.name, :type=>params[:type]}
      self.new
      false
    else
      render :action=>'missing' 
      false     
    end
  end

  def load_card
    return @card=nil unless id = params[:id]
    return (@card=Card.find(id); @card.include_set_modules; @card) if id =~ /^\d+$/
    name = Wagn::Cardname.unescape(id)
    card_params = params[:card] ? params[:card].clone : {}
    @card = Card.fetch_or_new(name, card_params)
  end

  def load_card_and_revision
    params[:rev] ||= @card.revisions.count - @card.drafts.length
    @revision_number = params[:rev].to_i
    @revision = @card.revisions[@revision_number - 1]
  end


  # ----------( rendering methods ) -------------


  def render_denied(action = '')
    Rails.logger.debug "~~~~~~~~~~~~~~~~~in render_denied for #{action}"
    
    @deny = action
    render :controller=>'card', :action=>'denied', :status=>403
    return false
  end

  def render_card_errors(card=nil)
    card ||= @card
    body = %{<div class="error-explanation">
      <h2>Rats. Issue with #{card.name && card.name.upcase} card:</h2>} +
      card.errors.map do |attr, msg|
        "<div>#{attr.to_s.gsub(/base/, 'captcha').upcase }: #{msg}</div>"
      end.join + '</div>'

    if ajax?
      render :text=>body, :status=>422
    else
      render :inline=>body, :layout=>'application', :status=>422
    end
  end

end


