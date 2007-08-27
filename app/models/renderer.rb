require 'diff'
require_dependency 'models/wiki_reference'
#require_dependency 'application_helper'
#require_dependency 'card_helper'

class Renderer                
  include HTMLDiff
  include ReferenceTypes
  #include Singleton
  attr_accessor :rescue_errors
  
  def render_without_rescue(*args)
    self.rescue_errors = false
    result = render(*args)
    self.rescue_errors = true
    result
  end
  
  def initialize
    @render_stack = [] 
    @rescue_errors = true
  end

  def render( card=nil, content=nil, update_references=false, &process_block )
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

    # FIXME: there is case here, I think when reverting links in content transcluded
    # from another card, that the @content reference held in the chunks doesn't match
    # the 'wiki_content' here, which causes the while loop below go forever.
    if wiki_content.chunks.find {|c| c.instance_variable_get('@content')!=wiki_content }
      raise "can't revert transcluded content when processing card '#{card.name}'; "
    end
    
    while wiki_content.chunks.length > 0
      warn "chunk length #{wiki_content.chunks.length}"
      wiki_content.chunks[0].revert
    end
    wiki_content
  end
      
  protected
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


