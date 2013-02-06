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

    attr_accessor :link_text

    def initialize match, card_params, params
      super
      if name=params[2]
        name, ltext = name.split('|',2)
        self.cardname = name.to_name
        self.link_text= ltext.nil? ? name :
          ltext =~ /(^|[^\\]){{/ ? ObjectContent.new(ltext, @card_params) : ltext
      else
        self.link_text= params[3]; self.cardname = params[4].to_name #.gsub(/_/,' ')
      end
      #warn "init link #{match} .. #{params.inspect} chk #{inspect} cl:#{@link_text.class}, #{@link_text}, #{@text}, cn:#{cardname}"
      self
    end

    def process_chunk
      @process_chunk ||= render_link
    end

    def replace_reference old_name, new_name
      @cardname=@cardname.replace_part old_name, new_name if @cardname
      if ObjectContent===self.link_text
        self.link_text.find_chunks(Chunks::Reference).each {|chunk| chunk.replace_reference old_name, new_name}
      else
        self.link_text = new_name if old_name.to_name == self.link_text
      end
      @text = self.link_text.nil? || cardname == self.link_text ? "[[#{cardname.to_s}]]" : "[[#{cardname.to_s}|#{self.link_text}]]"
    end
  end
end
