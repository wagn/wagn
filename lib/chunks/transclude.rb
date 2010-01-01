module Chunk
  class Transclude < Reference
    attr_reader :stars
    unless defined? TRANSCLUDE_PATTERN
      #  {{+name|attr:val;attr:val;attr:val}}
      TRANSCLUDE_PATTERN = /\{\{(((#{'\\'+Cardname::JOINT})?[^\|]+?)\s*(\|([^\}]+?))?)\}\}/
    end         
    
    def self.pattern() TRANSCLUDE_PATTERN end
  
    def initialize(match_data, content)
      super   
      #warn "FOUND TRANSCLUDE #{match_data} #{content}"
      @card_name, @options, @configs = self.class.parse(match_data)
      @relative = @options[:relative]
      @renderer = @content.renderer
      @card = @content.card or raise "No Card in Transclude Chunk!!"     
      @card_name.gsub!(/_self/,@card.name)
      @unmask_text = @text 
    end
  
    def self.parse(match)
      name = match[2].strip
      relative = match[3]
      options = {
        :tname   =>name,
        :relative=>relative,
        :base  => 'self',
        :view  => nil,
        :item  => nil,
        :type  => nil,
        :size  => nil,
      }
      style = {}
      configs = Hash.new_from_semicolon_attr_list match[5]
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

  end
end
