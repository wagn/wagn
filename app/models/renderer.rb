require 'diff'
require_dependency 'models/wiki_reference'
#require_dependency 'application_helper'
#require_dependency 'card_helper'

module Renderer                
  class Base
    include HTMLDiff
    include ReferenceTypes
    
    # and the Wagn Helpers
    include WagnHelper
    include CardHelper
    
    attr_reader :template
    attr_accessor :rescue_errors
    
    def render_without_rescue(*args)
      self.rescue_errors = false
      result = render(*args)
      self.rescue_errors = true
      result
    end
    
    def initialize(template, card)
      @template = template
      @card = card
      @render_stack = [] 
      @rescue_errors = true
    end

    def render( card=nil, content=nil, update_references=false, &process_block )
      card ||= @card
      @card ||= card  
      wiki_content = common_processing(card, content, update_references, &process_block)
      #warn  "CALLNG POST_RENDER on #{card.class}:#{card.name}"
      card.post_render( wiki_content.render! )
=begin
    rescue Exception=>e 
      if @rescue_errors
        WikiContent.new(card, "Error rendering #{card.name}: #{e.message}", self).render!
      else
        raise e
      end
=end
    end

    def render_diff( card, content1, content2 )
      diff( self.render( card, content1), self.render(card, content2) )
    end

    # process is used to make systematic transformations on cards that require
    # knowledge at the rendering level-- for example updating links when a card
    # has been renamed.
    def process( card, content=nil, update_references=true, &process_block )
      wiki_content = common_processing(card, content, update_references, &process_block)
      # wow, this doesnt' work: chunks.each { |c| c.revert }
      while wiki_content.chunks.length > 0
        wiki_content.chunks[0].revert
      end
      wiki_content
    end
    
    # FIXME -- what the heck is this doing in here? 
    def sidebar_cards
      cards = Card.find_by_wql(%{
        cards where plus_sidebar is not true and tagged by cards with name='*sidebar'
      })
      if @card && @card.id
        cards += Card.find_by_wql(%{
          cards where trunk_id=#{card.id}
          and (tags are cards where plus_sidebar is true 
                  and tagged by cards with name='*sidebar')
        })
      end
      cards = cards.sort_by {|c| 
        if c = Card.find_by_name(c.name + '+*sidebar')
          c.content.to_i 
        else
          0
        end
      }
    end
    
    def connection_cards
      load_cards( :id=>@card.id, :query=>'plus_cards' )
    end

    def extra_options
      ''
    end    
    
    protected
      def method_missing(method, *args)
        @template.send(method, *args)
      end
    
      def common_processing( card, content=nil, update_references=false)
        raise "Renderer.render() requires card" unless card
        if @render_stack.plot(:name).include?( card.name )
          raise Wagn::Oops, %{Circular transclusion; #{@render_stack.plot(:name).join(' --> ')}\n}
        end
        @render_stack.push(card)      
        # FIXME: this means if you had a card with content, but you WANTED to have it render 
        # the empty string you passed it, it won't work.  but we seem to need it because
        # card.content='' in set_card_defaults and if you make it nil a bunch of other
        # stuff breaks
        content = content.blank? ? card.template.content_for_rendering  : content 
        
        wiki_content = WikiContent.new(card, content, self)
        yield wiki_content if block_given?
        update_references(card, wiki_content) if update_references
        @render_stack.pop
        wiki_content
      end  
      
      def root_card
        @render_stack[0]
      end
      
      def current_card
        @render_stack[-1]
      end
      
      def update_references(card, rendering_result)
        WikiReference.delete_all ['card_id = ?', card.id]
        
        rendering_result.find_chunks(Chunk::Reference).each do |chunk|
       #  warn "   reference basename: #{chunk.send(:base_card).name} #{chunk.class} #{chunk.card_name} #{chunk.refcard_name}"
          reference_type = 
            case chunk
              when Chunk::Link;       chunk.refcard ? LINK : WANTED_LINK
              when Chunk::Transclude; chunk.refcard ? TRANSCLUSION : WANTED_TRANSCLUSION
              else raise "Unknown chunk reference class #{chunk.class}"
            end
          #warn "  CREATING REFERNCE #{card.name}:#{card.id} --> #{chunk.refcard_name} #{reference_type}"
          WikiReference.create!(
            :card_id=>card.id,
            :referenced_name=>chunk.refcard_name, 
            :referenced_card_id=> chunk.refcard ? chunk.refcard.id : nil,
            :link_type=>reference_type
          )
        end
      end
  end
  
  class StubController
    def url_for(*args)
      "LINK ME, OK?"
    end
          
    def render_to_string(*args)
      "stub render"
    end
  end
    
  class StubTemplate < ActionView::Base
    def initialize
      super
      self.controller = StubController.new 
    end
    def context
      return {}
    end
  end
  
  class << self
    def new( template, card=nil ) 
      #warn "Card class: #{card.class}, renderer class: #{ renderer_class_for_card_class( card.class ) }"
      renderer = card.nil? ?  Renderer::Base.new( template, card ) :
        renderer_class_for_card_class( card.class ).new( template, card )
      @instance = renderer
    end
    
    def instance
      if @instance.nil? 
        new( StubTemplate.new )
      end
      @instance
    end
    
    private
      def renderer_class_for_card_class( card_class )
        class_name = card_class.to_s.gsub(/^Card::/,'').to_s + "Renderer"
        return Renderer::Base if class_name=='BaseRenderer'
        begin
          require_dependency("renderers/" + class_name.underscore) unless Object.const_defined?( class_name )
        rescue MissingSourceFile
          # nada
        end
        if Object.const_defined?( class_name )
          Object.const_get( class_name )
        else
          renderer_class_for_card_class( card_class.superclass )
        end
      end
  end
end


