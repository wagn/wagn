
# # Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  require_dependency 'exception_system' 
  include AuthenticatedSystem
  include ExceptionNotifiable
  include ExceptionSystem
  
  layout :ajax_or_not, :except=>[:render_fast_404]
  attr_reader :card, :cards, :renderer, :context   
  attr_accessor :notice
  before_filter :per_request_setup
    #:note_current_user, :load_context, :reset_class_caches, :save_request, :note_time 
  helper_method :card, :cards, :renderer, :context, :previous_page, 
    :edit_user_context, :sidebar_cards, :notice, :slot, :url_for_page, :url_for_card
  
  ## This is a hack, but lots of stuff seems to break without it
  #include WagnHelper 

  helper :wagn
  attr_accessor :slot

  include ActionView::Helpers::TextHelper #FIXME: do we have to do this? its for strip_tags() in edit()
  include ActionView::Helpers::SanitizeHelper
   
  protected
  
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
    
    System.request = request 
    System.time = Time.now.to_f

  end
  
  def edit_ok
    @card.ok! :edit
  end
  
  def create_ok
    if params[:card] and cardtype = params[:card][:type]  
      Card.const_get(cardtype).create_ok!
    elsif Cardtype.createable_cardtypes.empty?
      raise Wagn::PermissionDenied, "Sorry, you don't have permission to create new cards"
    end  
  end
  
  def remove_ok
    @card.ok! :delete
  end

  def load_card!
    load_card
    if @card.new_record? && !@card.phantom?
      raise Wagn::NotFound, "#{request.env['REQUEST_URI']} requires a card id"
    end
  end

  def load_card_with_cache
    load_card( cache=true )
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
    if @card.new_record?
      @card.send(:set_defaults)
    end
    @card
  end
                
  def load_card_and_revision
    params[:rev] ||= @card.revisions.count - @card.drafts.length
    @revision_number = params[:rev].to_i
    @revision = @card.revisions[@revision_number - 1]      
  end  
  

  def handle_cardtype_update(card)
    #FIXME -- only used in connection controller.  should be phased out.
    if updating_type?  
#      old_type = card.type
      card.type=params[:card][:type]  
      card.save!
      card = Card.find(card.id)
      content = params[:card][:content]
      content = strip_tags(content) unless (card.class.superclass.to_s=='Card::Basic' or card.type=='Basic')
      card.content = content
    end
    card
  end
  
  def updating_type?
    request.post? and params[:card] and params[:card][:type]
  end
  
  def ajax_or_not
    request.xhr? ? nil : (
      case params[:layout]
        when nil; 'application'
        when 'none'; nil
        else params[:layout]
      end
    )
  end
  
  def render_jsonp( args )
    str = render_to_string args
    render :json=>( params[:callback] || "wadget") + '(' + str.to_json + ')'
  end
  
  def remember_card( card )
    
    #warn "SESSION RETURN STACK:  #{session[:return_stack].inspect}"
    
    return unless card
    session[:return_stack] ||= [] 
    session[:return_stack].push( card.id ) unless session[:return_stack].last == card.id
    session[:return_stack].shift if session[:return_stack].length > 4 
  end
  
  def return_to_remembered_page( options={} )
    redirect_to_page url_for_previous_page, options
  end
  
  def previous_page    
    # FIXME please
    name = ''
    session[:return_stack] ||= []
    session[:return_stack].reverse.each do |id|
      #warn "EXAMINING CARD ID: #{id}"
      if ((Fixnum === id && card = Card.find_by_id_and_trash( id, false )) || 
            card=Card.find_by_key_and_trash( id, false ))
        name = card.name
        break
      end
    end
    name
  end
  
  def url_for_previous_page
    name = previous_page
    name.empty? ? '/' : url_for_page( name )
  end        
  
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
  
   ## FIXME should be using rjs for this...
  def redirect_to_page( url, options={} )
    #url = name.empty? ? '/' : url_for_page( name )
    if options[:javascript] 
      render :inline=>%{<%= javascript_tag "document.location.href='#{url}'" %>Returning to previous card...}
    else
      redirect_to url 
    end    
  end   
       
  # Urls -----------------------------------------------------------------------
  def url_for_page( title, opts={} )   
    # shaved order of magnitude off footer rendering
    # vs. url_for( :action=> .. )
    "/wagn/#{Cardname.escape(title)}"
  end  
  
  def url_for_card( options={} )
    url_for options_for_card( options )
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
