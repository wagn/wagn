module Chunk
  class Transclude < Reference
    attr_reader :stars, :inclusion_map
    unless defined? TRANSCLUDE_PATTERN
      #  {{+name|attr:val;attr:val;attr:val}}
      TRANSCLUDE_PATTERN = /\{\{(([^\|]+?)\s*(\|([^\}]+?))?)\}\}/
    end         
    
    def self.pattern() TRANSCLUDE_PATTERN end
  
    def initialize(match_data, content)
      super   
      #warn "FOUND TRANSCLUDE #{match_data} #{content}"
      @card_name, @options, @configs = self.class.parse(match_data)
      @inclusion_map = content.inclusion_map
    end
  
    def self.parse(match)
      name = match[2].strip
      case name
      when /^\#\#/; return [nil, {:comment=>''}] # invisible comment
      when /^\#/||nil?||blank?  # visible comment
        return [nil, {:comment=>"<!-- #{CGI.escapeHTML match[1]} -->"}]
      end
      options = {
        :tname   =>name,
        :base  => 'self',
        :view  => nil,
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
      options[:style] = style.map{|k,v| CGI.escapeHTML("#{k}:#{v};")}.join
      [name, options, configs]  
    end                        
    
    def unmask_text(&block)
      return @unmask_text if @unmask_text
      comment = @options[:comment]
      return comment if comment
      refcard_name
      if view = @options[:view]
        view = view.to_sym
        if inclusion_map and inclusion_map.key?(view)
          view = @options[:view] = inclusion_map[view]
        end
      end
      case view
      when :name;     refcard ? refcard.name : @card_name
      when :key;      refcard_name.to_key
      when :link;     card_link
      when :linkname; Cardname.escape(refcard_name)
      else
        block ||= Proc.new do |tcard, opts|
          case view
        when nil
            @card=Card.fetch_or_new(@card_name) if @card_name != @card.name
            raw_content(@card)
          when :naked, :get_raw
            card = Card.fetch(tcard)
            return "<no card #{tcard}/>" unless card
            if card.is_collection?
              card.each_name do |name|
                raw_content(Card.fetch_or_new(name))
              end
            else
              raw_content(card)
            end
          else
            @text # just leave the {{}} coding, may need to handle more...
          end
        end
Rails.logger.debug "transclude #{@card_name}, #{@options.inspect}"
        block.call(@card_name, @options)
      end
    end

    def raw_content(card)
      return "<no card #{@tcard}/>" unless card
      card.templated_content || card.content
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
