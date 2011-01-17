module Chunk
  class Transclude < Reference
    attr_reader :stars, :inclusion_map, :renderer, :options, :base
    unless defined? TRANSCLUDE_PATTERN
      #  {{+name|attr:val;attr:val;attr:val}}
      TRANSCLUDE_PATTERN = /\{\{(([^\|]+?)\s*(\|([^\}]+?))?)\}\}/
    end         
    
    def self.pattern() TRANSCLUDE_PATTERN end
  
    def initialize(match_data, content)
      super   
      #warn "FOUND TRANSCLUDE #{match_data} #{content}"
      @card_name, @options, @configs = self.class.parse(match_data)
      @base, @renderer, @inclusion_map =
         content.card, content.renderer, content.inclusion_map
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
      when :name;     refcard ? refcard.name : card_name
      when :key;      refcard_name.to_key
      when :link;     card_link
      when :linkname; Cardname.escape(refcard_name)
      else
	      Rails.logger.info "unmask yields #{card_name} #{options.inspect}"
        yield card_name, options
      end
    end

    def revert                             
      configs = @configs.to_semicolon_attr_list;  
      configs = "|#{configs}" unless configs.blank?
      @text = "{{#{card_name}#{configs}}}"
      super
    end
    
    private
    def base_card 
      case options[:base]
      when 'self'  ; card
      when 'parent'; card.trunk
      else           base || invalid_option(:base)
      end
    end
    
    def invalid_option(key)
      raise Wagn::Oops, "Invalid argument {'#{key}': '#{options[key]}'} in transclusion syntax"
    end

  end
end
