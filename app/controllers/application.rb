# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  require_dependency 'exception_system' 
#  require_dependency 'datatype'
  include AuthenticatedSystem
  include ExceptionNotifiable
  include ExceptionSystem
  #model :system, :card, :renderer, :wag_bot, :datatype
  
  layout :ajax_or_not
  attr_reader :card, :cards, :renderer, :context 
  before_filter :note_current_user, :load_renderer, :load_context, :save_request 
  helper_method :card, :cards, :renderer, :context, :load_cards, :previous_page, :edit_user_context
  
  ## This is a hack, but lots of stuff seems to break without it
  helper :wagn
  include WagnHelper 
  
  protected
    def load_card        
      if params[:id]  =~ /^\d+$/
        @card = Card.find(params[:id])
      else
        @card = Card.find_by_name(params[:id]) 
      end
      @tag = @card.tag
      load_renderer  # in case it ran before @card was set
    end

    def load_cards_from_params   
      options = params.clone   
      %w{ action controller }.each {|key| options.delete(key) }
      load_cards( options )
    end

    def load_cards( options={} ) 
      options.keys.each {|k| options[k.to_sym]=options[k] }
      #warn "LOAD CARDS OPTIONS: #{options.inspect}"
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
      
      load_renderer  # in case it ran before @card was set    
      
      if @hide_duplicates
        # for connections, we want to skip cards that have already been displayed     
        included_names = []
        included_names += @card.out_transclusions.plot(:referenced_name) if @card
        included_names += cards.plot(:out_transclusions).flatten.plot(:referenced_name)
        included_names += @renderer.sidebar_cards().plot(:name)
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
      
      @cards
    end
    
    def load_card_and_revision
      params[:rev] ||= @card.revisions.count - @card.drafts.length
      @revision_number = params[:rev].to_i
      @revision = @card.revisions[@revision_number - 1]
    end  
    
    # a context struct holds all the info a card need to render properly--
    # for instance if a card renders via an ajax call inside a nested list of cards,
    # it may need to know what card it's inside, what the base card for the page is--
    # it needs to know what DOM element it's inside so that ajax links can be set to update
    # the right space.  all this info needs to be passed in with the request.  
    # It's not clear to me that all of these are needed, but at the moment I'm trying not
    # to break stuff.  --LWH
    def load_context
      @context = {
        :action  => params[:action],
        :parent  => params[:parent_id] ? Card.find(params[:parent_id]) : @card,
        :base    => params[:base_id] ? Card.find(params[:base_id]) : @parent,
        :partial => params[:partial] || 'full',
        :context => params[:context] || 'main-workspace',
        :element => params[:element] || 'main-workspace'
      }
    end
    
    def load_renderer
      @renderer = Renderer.new( self.response.template, @card )
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
      if System.ok?(:manage_permissions)
      	'admin'
      elsif current_user == card.extension
      	'user'
      else
      	'public'
      end
    end
  
  private
    def save_request
      System.request = request 
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
    
 
end
