
# # Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  require_dependency 'exception_system' 
  include AuthenticatedSystem
  include ExceptionNotifiable
  include ExceptionSystem

  include LocationHelper
  helper :all

  attr_reader :card, :cards, :renderer, :context   
  attr_accessor :notice, :slot
  
  helper_method :card, :cards, :renderer, :context, 
    :edit_user_context, :sidebar_cards, :notice, :slot

  include ActionView::Helpers::TextHelper #FIXME: do we have to do this? its for strip_tags() in edit()
  include ActionView::Helpers::SanitizeHelper

  before_filter :per_request_setup, :except=>[:render_fast_404]                  
  before_filter :set_canonical_domain
  
  # OPTIMIZE: render_fast_404 still isn't that fast (?18reqs/sec) 
  # can we turn sessions off for it and see if that helps?
  layout :default_layout, :except=>[:render_fast_404]

  protected
  
  def set_canonical_domain
    requested_base =  "#{request.protocol}#{(request.subdomains.blank? ? '' : (request.subdomains.join('.') + '.'))}#{request.domain}#{request.port_string}"
    logger.info("*************************************************************")
    logger.info( "#{requested_base} == #{System.base_url}" )

    unless requested_base == System.base_url || (requested_base+'/') == System.base_url
      redirect_to "#{System.base_url.gsub(/\/$/,'')}#{request.path}"    if "#{request.protocol}#{request.subdomains}#{request.domain}#{request.port_string}/" != System.base_url
    end
  end
                
  
  def per_request_setup
    User.current_user = current_user || User.find_by_login('anon')
    
    @context = params[:context] || 'main_1'
    @action = params[:action]
    
    # reset class caches
    # FIXME: this is a bit of a kluge.. several things stores as cattrs in modules
    # that need to be reset with every request (in addition to current user)
    Card.reset_cache
    Cardtype.reset_cache
    Role.reset_cache
    CachedCard.reset_cache
    System.request = request 
    System.time = Time.now.to_f              

  end

  def default_layout
    request.xhr? ? nil : (
      case params[:layout]
        when nil; 'application'
        when 'none'; nil
        else params[:layout]
      end
    )
  end
           

  # ------------( helpers ) --------------
  def edit_user_context(card)
    if System.ok?(:administrate_users)
    	'admin'
    elsif current_user == card.extension
    	'user'
    else
    	'public'
    end
  end

  def renderer
    Renderer.new
  end
  

  # ------------------( permission filters ) -------
  def view_ok
    unless @card.ok? :read
      @deny = 'view'
      render :action=>'denied', :status=>403
      return false
    end
  end    
  
  def edit_ok
    unless @card.ok? :edit
      render :action=>'denied', :status=>403
      return false
    end
  end
  
  def create_ok
    @type = params[:type] || (params[:card] && params[:card][:type]) || 'Basic'
    @skip_slot_header = true
    t = Card.class_for(@type) || Card::Basic
    unless t.create_ok?
      render :action=>'denied', :status=>403
      return false
    end
  end
  
  def remove_ok
    @card.ok! :delete
  end


  # --------------( card loading filters ) ----------
  def load_card!
    load_card
    if @card.new_record? && !@card.phantom?
      raise Wagn::NotFound, "#{request.env['REQUEST_URI']} requires a card id"
    end
  end

  def load_card_with_cache
    return load_card( cache=true )
  end

  def load_card( cache=false)                
    if params[:id] && params[:id] =~ /^\d+$/
      @card = Card.find(params[:id])
      name = @card.name
    elsif params[:id]
      name = Cardname.unescape( params[:id] )
    else 
      name=""
    end
    # auto_load_card tells the cached card if any missing method is requested
    # load the real card to respond.  
    card_params = params[:card] ? params[:card].clone : nil
    @card = CachedCard.get(name, @card, :cache=>cache, :card_params=>card_params )
    @card
    
    return view_ok
  end
                
  def load_card_and_revision
    params[:rev] ||= @card.revisions.count - @card.drafts.length
    @revision_number = params[:rev].to_i
    @revision = @card.revisions[@revision_number - 1]      
  end  
  

  # ----------( rendering methods ) -------------

  def render_jsonp( args )
    str = render_to_string args
    render :json=>( params[:callback] || "wadget") + '(' + str.to_json + ')'
  end

  def render_update_slot(stuff="", &proc )
    render_update_slot_element(name="", stuff,&proc)                   
  end
          
  # FIXME: this should be fixed to use a call to getSlotElement() instead of default
  # selectors, so that we can reject elements inside nested slots.
  def render_update_slot_element(name,stuff="")
    render :update do |page|
      page.extend(WagnHelper::MyCrappyJavascriptHack) 
      elem_code = "getSlotFromContext('#{get_slot.context}')"
      unless name.empty?
        elem_code = "getSlotElement(#{elem_code}, '#{name}')"
      end
      page.select_slot(elem_code).each() do |target,index|
        target.update(stuff) unless stuff.empty?
        yield(page, target) if block_given?
      end
    end
  end
end
