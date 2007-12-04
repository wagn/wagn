
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
  before_filter :note_current_user, :load_context, :reset_class_caches, :save_request 
  helper_method :card, :cards, :renderer, :context, :load_cards, :previous_page, 
    :edit_user_context, :sidebar_cards, :notice, :slot, :url_for_page, :url_for_card
  
  ## This is a hack, but lots of stuff seems to break without it
  #include WagnHelper 

  helper :wagn
  attr_accessor :slot

  include ActionView::Helpers::TextHelper #FIXME: do we have to do this? its for strip_tags() in edit()
   
  protected  
  def edit_ok
    @card.ok! :edit
  end
  
  def create_ok
    if params[:card] and cardtype = params[:card][:type]
      Cardtype.find_by_class_name(cardtype).card.me_type.ok! :create
    elsif User.current_user.createable_cardtypes.empty?
      raise Wagn::PermissionDenied, "Sorry #{::User.current_user.cardname}\, you don't have permission to create new cards"
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
    @card = CachedCard.get(name, @card, :cache=>cache, :card_params=>params[:card] )
    if @card.new_record?
      @card.send(:set_defaults)
    end
    @card
  end

  def load_cards_from_params   
    options = params.clone   
    %w{ action controller }.each {|key| options.delete(key) }
    load_cards( options )
  end

  def load_cards( options={} ) 
    options.keys.each {|k| options[k.to_sym]=options[k] }
    options[:keyword].gsub!(/[^\w]/,' ') if options[:keyword]
    @title = options.delete(:title)
        
    if options[:card]
      @card = options.delete(:card)
    elsif id = options.delete(:id) and !id.to_s.empty?
      @card = Card.find(id)
    else 
      @card = nil
    end
    card_id = @card ? @card.id : nil
       
    @hide_duplicates = options.delete(:hide_duplicates)

    @duplicate_count = 0
    @duplicates = []
    @cards = []
    
    if options[:query]  
      case options.delete(:query)
      when 'common_tags';    options[:tagging]={:type=>@card.class.to_s.gsub(/^Card::/,'') }; options[:sort_by]='cards_tagged'; options[:sortdir]="desc"
      when 'connections';    options[:plus]={ :id=> card_id }
      when 'plus_cards';     options[:plus]={ :id=> card_id }
      when 'plussed_cards';  options[:connected]={ :id=>card_id }
      when 'recent_changes'; options[:sort_by]='updated_at'; options[:sortdir]='desc'
      when 'search';
      when 'cardtype_cards'; options[:type]=@card.extension.class_name
      when 'pieces';         options[:pieces]=true; options[:id]=card_id
      when 'backlinks';      options[:backlink]={ :id=>card_id }
      when 'revised_by';     options[:editors]=(@card.extension ? @card.extension.id : nil); options[:sort_by]='updated_at'; options[:sortdir]='desc'
      end
    end

    warn "wql options: #{options.inspect}" if System.debug_wql
    cards = Card.find_by_wql_options( options )

    if @hide_duplicates
      # for connections, we want to skip cards that have already been displayed     
      included_names = []
      included_names += @card.out_transclusions.plot(:referenced_name) if @card
      included_names += cards.plot(:out_transclusions).flatten.plot(:referenced_name)
      included_names += @card.sidebar_cards.plot(:name)
      included_names.length

      cards.each do |c|
        if included_names.include?(c.name)  
          @duplicates << c
        else
          @cards << c
        end
      end
      @duplicate_count = @duplicates.length
    else  
      @cards = cards
    end  
    #@cards = @cards.map {|c| c.ok?(:read) ? c : Card.new(:name=>"Error:#{c.name}", :content=>"Permission Denied") }
    @cards
  end
                
  def load_card_and_revision
    params[:rev] ||= @card.revisions.count - @card.drafts.length
    @revision_number = params[:rev].to_i
    @revision = @card.revisions[@revision_number - 1]      
  end  
  
  def load_context
    @context = params[:context] || 'main_1'
    @action = params[:action]
  end 
  
  def reset_class_caches
    # FIXME: this is a bit of a kluge.. several things stores as cattrs in modules
    # that need to be reset with every request (in addition to current user)
    Card.load_cardtypes!
    Role.cache = {}
    Card.cache = {}
    User.cache = {}
  end
  
  def sidebar_cards
    unless @sidebar_cards 
      cards = Card.search( :plus=>'*sidebar')
=begin
      # FIXME: are we using this?
      if @card && @card.id
        cards += Card.find_by_wql(%{
          cards where trunk_id=#{card.id}
          and (tags are cards where plus_sidebar is true 
                  and tagged by cards with name='*sidebar')
        })
      end
=end
     @sidebar_cards = cards.sort_by do |c| 
        (side = Card.find_by_name(c.name + '+*sidebar')) ? side.content.to_i : 0
      end
    end
    @sidebar_cards.map do |card|
      CachedCard.get(card.name, card) 
    end
  end  
  
  def handle_cardtype_update(card)
    if updating_type?  
      old_type = card.type
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
  
  def log_viewing
    RecentViewing.log( self ) if ajax_or_not
  end  
  
  def render_jsonp( args )
    str = render_to_string args
    render :json=>( params[:callback] || "wadget") + '(' + str.to_json + ')'
  end
  
  def note_current_user
    User.current_user = current_user || User.find_by_login('anon')
  end

  def remember_card( card )
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
      if ((id =~ /^\d+$/ && card = Card.find_by_id_and_trash( id, false )) || 
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

  def save_request
    System.request = request 
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
      redirect_to_url url 
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
