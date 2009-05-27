require 'diff'
require_dependency 'models/wiki_reference'

class Renderer                
  include HTMLDiff
  include ReferenceTypes
  attr_accessor :rescue_errors

  class << self
    def instance
      Renderer.new
    end
  end
  
  def render_without_rescue(*args)
    self.rescue_errors = false
    result = render(*args)               
    self.rescue_errors = true
    result
  end
  
  def initialize()
    @render_stack = [] 
    @rescue_errors = true
  end

  def render_diff( card, content1, content2 )
    diff( self.render( card, content1), self.render(card, content2) )
  end

  def replace_references( card, old_name, new_name )
    content = common_processing(card, nil, false) do |wiki_content|
      wiki_content.find_chunks(Chunk::Link).each do |chunk|
        link_bound = chunk.card_name == chunk.link_text          
        chunk.card_name.replace chunk.card_name.replace_particle(old_name, new_name)
        chunk.link_text = chunk.card_name if link_bound
      end
      
      wiki_content.find_chunks(Chunk::Transclude).each do |chunk|
        chunk.card_name.replace chunk.card_name.replace_particle(old_name, new_name)
      end
    end
    String.new content.unrender!  
  end

  def render( card=nil, content=nil, update_references=false, &process_block )
    wiki_content = common_processing(card, content, update_references, &process_block)
    wiki_content.render! 
  rescue Exception=>e 
    if @rescue_errors
      WikiContent.new(card, "Error rendering #{card.name}: #{e.message}", self).render!
    else
      raise e
    end
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
    content = content.blank? ? card.content_for_rendering  : content 
    wiki_content = WikiContent.new(card, content, self)
    yield wiki_content if block_given?
    update_references(card, wiki_content) if update_references
    @render_stack.pop
    wiki_content
  end  
  
  def update_references(card, rendering_result)
    WikiReference.delete_all ['card_id = ?', card.id]
    
	 if card.id and card.respond_to?('references_expired')
    	card.connection.execute("update cards set references_expired=NULL where id=#{card.id}") 
    end
    
    rendering_result.find_chunks(Chunk::Reference).each do |chunk|
      reference_type = 
        case chunk
          when Chunk::Link;       chunk.refcard ? LINK : WANTED_LINK
          when Chunk::Transclude; chunk.refcard ? TRANSCLUSION : WANTED_TRANSCLUSION
          else raise "Unknown chunk reference class #{chunk.class}"
        end
      WikiReference.create!(
        :card_id=>card.id,
        :referenced_name=>chunk.refcard_name.to_key, 
        :referenced_card_id=> chunk.refcard ? chunk.refcard.id : nil,
        :link_type=>reference_type
      )
    end
  end
end


