# -*- encoding : utf-8 -*-

require_dependency File.expand_path("../reference", __FILE__)

module Card::Content::Chunk
  class Link < Reference
    CODE = "L".freeze # L for "Link"
    attr_reader :link_text
    # Groups: $1, [$2]: [[$1]] or [[$1|$2]] or $3, $4: [$3][$4]
    Card::Content::Chunk.register_class self,
                                        prefix_re: '\\[',
                                        full_re:   /^\[\[([^\]]+)\]\]/,
                                        idx_char:  "["
    def reference_code
      CODE
    end

    def interpret match, _content
      target, @link_text =
        if (raw_syntax = match[1])
          if (i = divider_index(raw_syntax))  # [[A | B]]
            [raw_syntax[0..(i - 1)], raw_syntax[(i + 1)..-1]]
          else                                # [[ A ]]
            [raw_syntax, nil]
          end
        end

      @link_text = objectify @link_text
      if target =~ %r{/|mailto:}
        @explicit_link = objectify target
      else
        @name = target
      end
    end

    def divider_index string
      # there's probably a better way to do the following.
      # point is to find the first pipe that's not inside an nest
      return unless string.index "|"
      string_copy = string.dup
      string.scan(/\{\{[^\}]*\}\}/) do |incl|
        string_copy.gsub! incl, ("x" * incl.length)
      end
      string_copy.index "|"
    end

    # view options
    def options
      link_text ? { title: link_text } : {}
    end

    def objectify raw
      return unless raw
      raw.strip!
      if raw =~ /(^|[^\\])\{\{/
        Card::Content.new raw, format
      else
        raw
      end
    end

    def render_link
      @link_text = render_obj @link_text

      if @explicit_link
        @explicit_link = render_obj @explicit_link
        format.link_to_resource @explicit_link, @link_text
      elsif @name
        known = referee_card.send_if :known?
        format.link_to_card referee_name, @link_text, known: known
      end
    end

    def process_chunk
      @process_chunk ||= render_link
    end

    def inspect
      "<##{self.class}:e[#{@explicit_link}]n[#{@name}]l[#{@link_text}]" \
      "p[#{@process_chunk}] txt:#{@text}>"
    end

    def replace_reference old_name, new_name
      replace_name_reference old_name, new_name

      if @link_text.is_a?(Card::Content)
        @link_text.find_chunks(Card::Content::Chunk::Reference).each do |chunk|
          chunk.replace_reference old_name, new_name
        end
      elsif old_name.to_name == @link_text
        @link_text = new_name
      end

      @text = if @link_text.nil?
                "[[#{referee_name}]]"
              else
                "[[#{referee_name}|#{@link_text}]]"
              end
    end
  end
end
