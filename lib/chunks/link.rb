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

    attr_reader :link_text, :ext_link

    def initialize match, card_params, params
      super
      if nm=params[2]
        nm = nm.strip
        @link_text = nil
        if nm =~ /(^|[^\\]){{/
          Rails.logger.warn "chunks? #{nm}"
          @name = nm = ObjectContent.new(nm, @card_params)
          pidx = 0
          nm.find do |chk|
            pidx += 1
            if String===chk && chk.index('|')
              bef, aft = chk.split(/\s*\|\s*/, 2)
              @link_text = nm.length > pidx ? nm[pidx..-1] : nil
              #warn "p1 #{nm.map(&:inspect)*', '}, l:#{nm.length}, pi:#{pidx}, [#{bef}::#{aft}] lt:#{@link_text.inspect}"
              if @link_text.nil?
                @link_text = aft unless aft.blank?
              elsif !aft.blank?
                @link_text = ObjectContent.new([aft] + @link_text, @card_params)
              end
              obj = pidx == 1 ? bef : ObjectContent.new( bef.blank? ? nm[0..pidx-2] : (nm[0..pidx-2] << bef), @card_params )
              if obj.first =~ %r{/}
                 @name = nil
                 @ext_link = obj
              else
                 @name = obj
              end
              #warn "pipe? #{nm.map(&:inspect)*', '}, #{nm.length}, #{pidx}, [#{bef}::#{aft}] lt:#{@link_text.inspect}, n:#{@name.inspect}"; @name
            end
          end
        elsif nm =~ %r{/}
          @ext_link, @link_text = nm.split(/\s*\|\s*/, 2)
          Rails.logger.warn "elink #{@ext_link}, #{@link_text}, #{@ext_link.class}, #{nm}"
        else
          @name, @link_text = nm.split(/\s*\|\s*/, 2)
          Rails.logger.warn "nlink #{@name}, #{@link_text}, #{@name.class}, #{nm}"
        end
        if !renderer.nil?
          objs = []
          ObjectContent===@link_text and objs << @link_text
          ObjectContent===@name      and objs << @name
          ObjectContent===@ext_link  and objs << @ext_link
          objs.each {|o| o.find_chunks(Chunks::Include) { |c| c.process_chunk } }
          @text = link_text_string
        end
      else # legacy [][] form
        if params[4] =~ /[\/:]/
          @link_text, @ext_link = params[3], params[4]
        else
          @link_text, @name = params[3], params[4]
        end
      end
      Rails.logger.warn "init link #{match} .. #{params.inspect} chk #{inspect} lclass:#{@link_text.class}, ltext:#{@link_text}, text:#{@text}, ext:#{@ext_link} n:#{@name}"
      self
    end

    def link_text_string
      link_text.nil? ? "[[#{reference_name.to_s}]]" : "[[#{reference_name.to_s}|#{link_text}]]"
    end

    def process_chunk
      @process_chunk ||= render_link
    end

    def inspect
      "<##{self.class}:e[#{@ext_link}]n[#{@name}]l[#{@link_text}] p[#{@process_chunk}] txt:#{@text}>"
    end

    def replace_reference old_name, new_name
      replace_name_reference old_name, new_name

      lt = link_text
      if ObjectContent===lt
        lt.find_chunks(Chunks::Reference).each { |chunk| chunk.replace_reference old_name, new_name }
      else
        @link_text = new_name if old_name.to_name == lt
      end
      @text = link_text_string
    end
  end
end
