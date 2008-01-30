module Chunk
  class Transclude < Reference
    attr_reader :stars
    unless defined? TRANSCLUDE_PATTERN
      
      #  {{+name|attr:val;attr:val;attr:val}}

    TRANSCLUDE_PATTERN = /\{\{((#{'\\'+JOINT})?[^\|]+?)\s*(\|([^\}]+?))?\}\}/
    end
    def self.pattern() TRANSCLUDE_PATTERN end
  
    def initialize(match_data, content)
      super   
      #warn "FOUND TRANSCLUDE #{match_data} #{content}"
      @card_name = match_data[1].strip    
      @relative = match_data[2]
      @options = {
        :view  => 'content',
        :base  => 'self',
        :state => 'open',      # deprecated
        :shade => 'on'         # deprecated
      }.merge(Hash.new_from_semicolon_attr_list(match_data[4]))
      @renderer = @content.renderer
      @card = @content.card or raise "No Card in Transclude Chunk!!"     
      @card_name.gsub!(/_self/,@card.name)
      @unmask_text = @text #get_unmask_text_avoiding_recursion_loops
    end
  
    private
    def base_card 
      case @options[:base]
      when 'self'; @card
      when 'parent'; @card.trunk
      else invalid_option(:base)
      end
    end
    
    def invalid_option(key)
      raise Wagn::Oops, "Invalid argument {'#{key}': '#{@options[key]}'} in transclusion syntax"
    end

    def get_unmask_text_avoiding_recursion_loops
      # FIXME why not template_tsars? what is relative? about?
      #if relative? and @card.template? #or @card.template_tsar? 
      if @card.template?
        return "#{@text}"
      end
#      if !refcard
#        return "<span class='faint'>{{#{@card_name}}}</span>\n"
#      end
      ActiveRecord::Base.logger.info("damn: unmaskme")
      
      card = refcard ? refcard : Card.new( :name=>refcard_name )
      result = @renderer.slot.process_transclusion(card, @options)
      if WikiContent===result
        @content.merge_chunks(result) 
        result = result.pre_rendered
      end
      result
    end
  #rescue Exception=>e     
  #  return "Error rendering transcluded card #{@card.name}: #{e.message}"
  end
end
