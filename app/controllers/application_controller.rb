# # Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  require_dependency 'exception_system'
  include AuthenticatedSystem
  include ExceptionSystem
  include LocationHelper
  helper :all

  helper_method :main_card?

  attr_accessor :renderer

  include ActionView::Helpers::TextHelper #FIXME: do we have to do this? its for strip_tags() in edit()
  include ActionView::Helpers::SanitizeHelper

  before_filter :per_request_setup, :except=>[:render_fast_404]
 # after_filter :set_encoding
  # OPTIMIZE: render_fast_404 still isn't that fast (?18reqs/sec) 
  # can we turn sessions off for it and see if that helps?
  layout :wagn_layout, :except=>[:render_fast_404]
  
  
 # def set_encoding
 #   respond_to do |format|
 #     format.text {  headers['Content-Type'] ||= 'text/css' }
 #     format.css {  headers['Content-Type'] ||= 'text/css' }
 #   end  
 # end
  
  BUILTIN_LAYOUTS = %w{ blank noside simple pre none }


  protected

  def per_request_setup
    Wagn::Renderer.ajax_call=request.xhr?
    if System.multihost
      MultihostMapping.map_from_request(request) or return render_fast_404(request.host)
    end
    Wagn::Cache.re_initialize_for_new_request
    canonicalize_domain
    
    User.current_user = current_user || User[:anon]

    @context = params[:context] || 'main_1'
    @action = params[:action]

    Wagn::Renderer.current_slot = nil
    System.request = request
    ActiveRecord::Base.logger.debug("WAGN: per request setup")
    load_location
  end
  
  def canonicalize_domain
    if RAILS_ENV=="production" and request.raw_host_with_port != System.host
      query_string = request.query_string.empty? ? '' : "?#{request.query_string}"
      return redirect_to("http://#{System.host}#{request.path}#{query_string}")
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

  # ----------- (helper) ----------
  def main_card?
    @context =~ /^main_([^\_]+)$/
  end


  # ------------------( permission filters ) -------
  def view_ok
    @card.ok?(:read) || render_denied('view')
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


  # --------------( card loading filters ) ----------
  def load_card!
    load_card
    case
    when !@card || @card.name.nil? || @card.name.empty?  #no card or no name -- bogus request, deserves error
      raise Wagn::NotFound, "We don't know what card you're looking for."
    when @card.known? # default case
      @card
    when params[:view]=='edit_rule'
      # FIXME this is a hack so that you can view load rules that don't exist.  need better approach 
      # (but this is not tested; please don't delete without adding a test) 
      @card
    when requesting_ajax? || ![nil, :html].member?(params[:format])  #missing card, nonstandard request
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
    return (@card=Card.find(id); @card.after_fetch; @card) if id =~ /^\d+$/
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

  # dormant code.
  def render_jsonp(args)
    str = render_to_string args
    render :json=>(params[:callback] || "wadget") + '(' + str.to_json + ')'
  end

  def render_update_slot(stuff="", message=nil, &proc)
    render_update_slot_element(name="", stuff, message, &proc)
  end

  # FIXME: this should be fixed to use a call to getSlotElement() instead of default
  # selectors, so that we can reject elements inside nested slots.
  def render_update_slot_element(name, stuff="", message=nil)
    render :update do |page|
      page.extend(WagnHelper::MyCrappyJavascriptHack)
      elem_code = "getSlotFromContext('#{params[:context]}')"
      unless name.empty?
        elem_code = "getSlotElement(#{elem_code}, '#{name}')"
      end
      page.select_slot(elem_code).each() do |target, index|
        target.update(stuff) unless stuff.empty?
        yield(page, target) if block_given?
      end
      page.wagn.messenger.log(message) if message
    end
  end

  def render_denied(action = '')
    Rails.logger.debug "~~~~~~~~~~~~~~~~~in render_denied for #{action}"
    
    @deny = action
    render :controller=>'card', :action=>'denied', :status=>403
    return false
  end

  def handling_errors
    if @card.errors.present?
      render_card_errors(@card)
    else
      yield
    end
  end

  def render_card_errors(card=nil)
    card ||= @card
    stuff = %{<div class="error-explanation">
      <h2>Rats. Issue with #{card.name && card.name.upcase} card:</h2><p>} +
        card.errors.map do |attr, msg|
          "#{attr.gsub(/base/, 'captcha').upcase }: #{msg}"
        end.join(",<br> ") +
        '</p></div>'

    # Create used this scroll
    #<%= javascript_tag 'scroll(0,0)'

    #errors.each{|attr,msg| puts "#{attr} - #{msg}" }
    # getNextElement() will crawl up nested slots until it finds one with a notice div

    on_error_js = ""

    if captcha_required? && ENV['RECAPTCHA_PUBLIC_KEY']
      key = card.new_record? ? "new" : card.name.to_key
      on_error_js << %{ document.getElementById('dynamic_recaptcha-#{key}').innerHTML='<span class="faint">loading captcha</span>'; }
      on_error_js << %{ Recaptcha.create('#{ENV['RECAPTCHA_PUBLIC_KEY']}', document.getElementById('dynamic_recaptcha-#{key}'),RecaptchaOptions); }
    end

    js_tag = %{<%= javascript_tag(%{#{on_error_js}}) %>}
    stuff_with_javascript = stuff + js_tag

    case
      when requesting_ajax? && !params['_update'];
        render :update do |page|
          page << %{notice = getNextElement(#{get_slot.selector},'notice');\n}
          page << %{notice.update('#{escape_javascript(stuff)}');\n}
          page << on_error_js
        end
      when requesting_ajax? && params['_update'];
        render :inline=>stuff_with_javascript, :layout=>nil, :status=>422
      when !requesting_ajax?;
        render :inline=>stuff_with_javascript, :layout=>'application', :status=>422
    end
  end

end


