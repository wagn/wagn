
# # Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  require_dependency 'exception_system' 
  include AuthenticatedSystem
  include ExceptionNotifiable
  include ExceptionSystem
  
  layout :ajax_or_not
  attr_reader :card, :cards, :renderer, :context   
  attr_accessor :notice
  before_filter :note_current_user, :load_context, :reset_class_caches, :save_request 
  helper_method :card, :cards, :renderer, :context, :load_cards, :previous_page, 
    :edit_user_context, :sidebar_cards, :notice
  
  ## This is a hack, but lots of stuff seems to break without it
  helper :wagn
  include WagnHelper 
  
  protected  
  def edit_ok
    @card.ok! :edit
  end
  
  def create_ok
    # FIXME (why?  what's wrong?)
    Card.ok! :create
  end
  
  def remove_ok
    @card.ok! :delete
  end

  def load_card!
    load_card
    if @card.new_record?
      raise Wagn::NotFound, "#{request.env['REQUEST_URI']} requires a card id"
    end
  end

  def load_card        
    if params[:id] && params[:id] =~ /^\d+$/
      @card = Card.find(params[:id])
    elsif params[:id]
      @card = Card.find_by_name(params[:id]) 
    else
      @card = Card.new params[:card]
      @card.send(:set_defaults)
    end

    @card.ok! :read        
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
      when 'revised_by';     options[:editors]=(@card.extension ? @card.extension.id : nil)
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
    @cards.each {|c| c.ok! :read }
    @cards
  end
                
  def load_card_and_revision
    params[:rev] ||= @card.revisions.count - @card.drafts.length
    @revision_number = params[:rev].to_i
    @revision = @card.revisions[@revision_number - 1]      
  end  
  
  def load_context
    @context = params[:context] || 'main'
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
      cards = Card.find_by_wql(%{
        cards where plus_sidebar is not true and tagged by cards with name='*sidebar'
      })

      # FIXME: are we using this?
      if @card && @card.id
        cards += Card.find_by_wql(%{
          cards where trunk_id=#{card.id}
          and (tags are cards where plus_sidebar is true 
                  and tagged by cards with name='*sidebar')
        })
      end

     @sidebar_cards = cards.sort_by do |c| 
        if c = Card.find_by_name(c.name + '+*sidebar') and c.ok?(:read)
          c.content.to_i 
        else
          0
        end
      end
    end
    @sidebar_cards
  end  
  
  def handle_cardtype_update(card)
    if updating_type?
      card.type=params[:card][:type]  
      card.save!
      card = Card.find(card.id)
      card.content = params[:card][:content]
    end
    card
  end
  
  def updating_type?
    request.post? and params[:card] and params[:card][:type]
  end
  
  def ajax_or_not 
    request.xhr? ? nil : 'application'
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
  
  def return_to_rememberd_page( options={} )
    redirect_to_page url_for_previous_page, options
  end
  
  def previous_page
    
    name = ''
    session[:return_stack] ||= []
    session[:return_stack].reverse.each do |id|
      if card = Card.find_by_id( id )
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
  
  def render_errors(card=nil)
    card ||= @card
    render :update do |page|
      page.replace_html slot.id(:notice), "#{card.errors.full_messages.join(',')}"
    end
  end
end
