require_dependency 'chunks/chunk'

module Chunks
  class Reference < Abstract
    attr_accessor :reference_name, :name

    def reference_name
      #warn "rercardname #{inspect}, E:#{@ext_link}, #{@name.inspect}"
      return if name.nil?
        
      @reference_name ||= ( renderer.nil? || !ObjectContent===name ? name : renderer.process_content( name ) ).to_name
      @reference_name = @reference_name.to_absolute(card.cardname).to_name
    end

    def reference_card
      @reference_card ||= reference_name && Card.fetch(reference_name, :new=>{})
    end

    def reference_id
      rc=reference_card and rc.id
    end

    def replace_name_reference old_name, new_name
      #warn "ref rnr #{inspect}, #{old_name}, #{new_name}"
      @reference_card = @reference_name = nil
      if ObjectContent===name
        name.find_chunks(Chunks::Reference).each { |chunk| chunk.replace_reference old_name, new_name }
      else
        @name = name.to_name.replace_part( old_name, new_name )
      end
    end

    def link_text
      reference_name.to_s
    end

    def render_link
      lt = link_text || @name
      lt = renderer.process_content( lt ) if ObjectContent===lt 
      if @name
        renderer.card_link reference_name, lt, reference_card.known?
      elsif @ext_link
        renderer.build_link @ext_link, lt
      end
    end
  end
end

