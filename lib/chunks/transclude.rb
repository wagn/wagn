module Chunk
  class Transclude < Reference
    attr_reader :stars
    unless defined? TRANSCLUDE_PATTERN
      #  {{+name|attr:val;attr:val;attr:val}}

    TRANSCLUDE_PATTERN = /\{\{((#{'\\'+JOINT})?[^\|]+?)\s*(\|([^\}]+?))?\}\}/
    end
    def self.pattern() TRANSCLUDE_PATTERN end
  
    def initialize(match_data, content, render_xml=false)
      super   
      #warn "FOUND TRANSCLUDE #{match_data} #{content}"
      @card_name, @options, @configs = self.class.parse(match_data)
      @relative = @options[:relative]
      @renderer = @content.renderer
      @card = @content.card or raise "No Card in Transclude Chunk!!"     
      @card_name.gsub!(/_self/,@card.name)
      @unmask_text = @text #get_unmask_text_avoiding_recursion_loops
    end
  
    def self.parse(match)
#      text = match[0]
      name = match[1].strip
      relative = match[2]
      options = {
        :tname   =>name,
        :relative=>relative,
        :view  => 'content',
        :base  => 'self',
        :item  => nil,
        :type  => nil,
        :size  => nil,
      }
      style = {}
      configs = Hash.new_from_semicolon_attr_list match[4]
      configs.each_pair do |key, value|
        if options.key? key.to_sym
          options[key.to_sym] = value
        else
          style[key] = value
        end
      end
      options[:style] = style.map{|k,v| "#{k}:#{v};"}.join
      [name, options, configs]  
    end                        
    
    def revert                             
      configs = @configs.to_semicolon_attr_list;  
      configs = "|#{configs}" unless configs.blank?
      @text = "{{#{@card_name}#{configs}}}"
      super
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
