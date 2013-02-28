require_dependency 'chunks/chunk'

module Chunks
  class Link < Reference
    word = /\s*([^\]\|]+)\s*/
    # Groups: $1, [$2]: [[$1]] or [[$1|$2]] or $3, $4: [$3][$4]
    WIKI_CONFIG = {
      :class     => Link,
      :prefix_re => '\\[',
      :rest_re   => /^\[([^\]]+)\]\]|([^\]]+)\]\[([^\]]*)\]/,
      :idx_char  => '['
    }

    def self.config() WIKI_CONFIG end

    def initialize match, card_params, params
      super
      target, @link_text = if params[2]     # standard [[ ]] syntax
        raw_syntax = params[2]
        if i = divider_index( raw_syntax )  # [[ A | B ]]
          [ raw_syntax[0..(i-1)], raw_syntax[(i+1)..-1] ]
        else                                # [[ A ]]
          [ raw_syntax, nil ]
        end
      else                                  # deprecated [ B ][ A ] syntax
        [ params[4], params[3] ]
      end
      
      @link_text = objectify @link_text
      if target =~ /[\/:]/
        @explicit_link = objectify target
      else
        @name = target
      end  
      
      self
    end

    def divider_index string
      #there's probably a better way to do the following.  point is to find the first pipe that's not inside an inclusion
      
      if string.index '|'
        string_copy = "#{string}" # had to do this to create new string?!
        string.scan /\{\{[^\}]*\}\}/ do |incl|
          string_copy.gsub! incl, ('x'*incl.length)
        end
        string_copy.index '|'
      end
    end

    def objectify raw
      if raw
        raw.strip!
        if raw =~ /(^|[^\\])\{\{/
          ObjectContent.new raw, @card_params
        else
          raw
        end
      end
    end


    def render_link
      @link_text = render_obj @link_text
      
      if @explicit_link
        @explicit_link = render_obj @explicit_link
        #warn "render link #{@explicit_link}"
        renderer.build_link @explicit_link, @link_text
      elsif @name
        renderer.card_link referee_name, @link_text, referee_card.send_if(:known?)
      end
    end

    def process_chunk
      @process_chunk ||= render_link
    end

    def inspect
      "<##{self.class}:e[#{@explicit_link}]n[#{@name}]l[#{@link_text}] p[#{@process_chunk}] txt:#{@text}>"
    end

    def replace_reference old_name, new_name
      replace_name_reference old_name, new_name

      if ObjectContent===@link_text
        @link_text.find_chunks(Chunks::Reference).each { |chunk| chunk.replace_reference old_name, new_name }
      else
        @link_text = new_name if old_name.to_name == @link_text
      end
      
      @text = @link_text.nil? ? "[[#{referee_name.to_s}]]" : "[[#{referee_name.to_s}|#{@link_text}]]"
    end
  end
end
