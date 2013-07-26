# -*- encoding : utf-8 -*-

module Card::Chunk
  class Include < Reference
    cattr_reader :options
    @@options = [ 
      :inc_name, :inc_syntax, :view, :item, :items, # deprecating :item
      :type, :size, :title, :hide, :show, :structure
    ].to_set
    attr_reader :options
      
    Card::Chunk.register_class self, {
      :prefix_re => '\\{\\{',
      :full_re   =>  /^\{\{([^\}]*)\}\}/,
      :idx_char  => '{'    
    }
    
    def interpret match, content
      in_brackets = match[1]
#      warn "in_brackets = #{in_brackets}"
      name, @opt_lists = in_brackets.split '|', 2
      result = case name.to_s
        when /^\#\#/ ; '' # invisible comment
        when /^\#/   ; "<!-- #{CGI.escapeHTML in_brackets} -->"
        when /^\s*$/ ; '' # no name
        else
          options_at_depth = @options = {}
          opt_list_array = @opt_lists.to_s.split '|'
          opt_list_array.each_with_index do |opt_list, index|            
            process_opt_list opt_list, options_at_depth
            if index + 1 < opt_list_array.size
              options_at_depth = options_at_depth[:items] = {}
            end
          end
          @options.merge! :inc_name => name, :inc_syntax => in_brackets
          @name = name
        end
      
      @process_chunk = result if !@name
    end
    
    def process_opt_list list_string, hash
      style_hash = {} 
      Hash.new_from_semicolon_attr_list( list_string ).each do |key, value|
        key = key.to_sym
        if @@options.include? key
          hash[key] = value
        else
          style_hash[key] = value
        end
      end
      
      if !style_hash.empty?
        hash[:style] = style_hash.map { |key, value| CGI.escapeHTML "#{key}:#{value};" } * ''
      end
    end

    def inspect
      "<##{self.class}:n[#{@name}] p[#{@process_chunk}] txt:#{@text}>"
    end

    def process_chunk
      return @process_chunk if @process_chunk

      referee_name
      if view = @options[:view]
        view = view.to_sym
      end

      @processed = yield @options # this is not necessarily text, sometimes objects for json
    end

    def replace_reference old_name, new_name
      replace_name_reference old_name, new_name
      @text = "{{#{ [ @name.to_s, @opt_lists ].compact * '|' }}}"
    end

  end
end
