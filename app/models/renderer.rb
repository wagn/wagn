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
    
    def initialize(template, card)
      @template = template
      @card = card
      @render_stack = [] 
    end

    def render( card=nil, content=nil, update_references=false, &process_block )
      card ||= @card
      @card ||= card
      wiki_content = common_processing(card, content, update_references, &process_block)
      card.post_render( wiki_content.render! )
    rescue Exception=>e 
      WikiContent.new(card, "Error rendering #{card.name}: #{e.message}", self).render!
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
        if card.template != card
          update_references=true
        end
        content ||= card.pre_render( card.template.content_for_rendering ) or raise "#{card.name} has NO CONTENT"
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
        #warn "update references #{card.name}"
        WikiReference.delete_all ['card_id = ?', card.id]
        
        rendering_result.find_chunks(Chunk::Reference).each do |chunk|
          #warn "   reference #{chunk.class} #{chunk.card_name} #{chunk.refcard_name}"
          reference_type = 
            case chunk
              when Chunk::Link;       chunk.refcard ? LINK : WANTED_LINK
              when Chunk::Transclude; chunk.refcard ? TRANSCLUSION : WANTED_TRANSCLUSION
              else raise "Unknown chunk reference class #{chunk.class}"
            end
          #warn "  CREATING REFERNCE #{card.name} --> #{chunk.refcard_name} #{reference_type}"
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


