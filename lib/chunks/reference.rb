require_dependency 'chunks/chunk'

module Chunks
  class Reference < Abstract
    attr_accessor :referee_name, :name

    def referee_name
      return if name.nil?
        
      @referee_name ||= ( renderer.nil? || !ObjectContent===name ? name : renderer.process_content( name ) ).to_name
      @referee_name = @referee_name.to_absolute(card.cardname).to_name
    end

    def referee_card
      @referee_card ||= referee_name && Card.fetch( referee_name )
    end

    def referee_id
      referee_card and referee_card.id
    end

    def replace_name_reference old_name, new_name
      #warn "ref rnr #{inspect}, #{old_name}, #{new_name}"
      @referee_card = @referee_name = nil
      if ObjectContent===name
        name.find_chunks(Chunks::Reference).each { |chunk| chunk.replace_reference old_name, new_name }
      else
        @name = name.to_name.replace_part( old_name, new_name )
      end
    end

    def link_text
      referee_name.to_s
    end
  end
end

