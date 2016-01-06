# -*- encoding : utf-8 -*-
module Card::Chunk
  class Reference < Abstract
    attr_accessor :referee_name, :name

    def referee_name
      return if name.nil?

      @referee_name ||= begin
        rendered_name = render_obj(name)
        ref_card =
          case rendered_name # FIXME: this should be standard fetch option.
          when /^\~(\d+)$/ # get by id
            Card.fetch $1.to_i
          when /^\:(\w+)$/ # get by codename
            Card.fetch $1.to_sym
          end
        ref_card ? ref_card.cardname : rendered_name.to_name
      end
      @referee_name = @referee_name.to_absolute(card.cardname).to_name
    end

    def referee_card
      @referee_card ||= referee_name && Card.fetch(referee_name)
    end

    # FIXME: if we need this, then it should be faster, using fetch_id
    # def referee_id
    #   referee_card and referee_card.id
    # end

    def replace_name_reference old_name, new_name
      @referee_card = nil
      @referee_name = nil
      if Card::Content === name
        name.find_chunks(Chunk::Reference).each do |chunk|
          chunk.replace_reference old_name, new_name
        end
      else
        @name = name.to_name.replace_part(old_name, new_name)
      end
    end

    def render_obj raw
      if format && Card::Content === raw
        format.card.references_expired = nil
        # don't love this; this is to keep from running update_references again
        format.process_content raw
      else
        raw
      end
    end
  end
end
