# -*- encoding : utf-8 -*-

module Card::Chunk
  class Include < Reference
    cattr_reader :options
    @@options = [ :include_name, :view, :item, :type, :size, :title, :hide, :show, :include, :structure ].
      inject({}) do |hash, key| hash[key] = nil; hash end
      
    Card::Chunk.register_class self, {
      :prefix_re => '\\{\\{',
      :full_re   =>  /^\{\{([^\}]*)\}\}/,
      :idx_char  => '{'    
    }
    
    def interpret match, content
      in_brackets = match[1]
#      warn "in_brackets = #{in_brackets}"
      opts = in_brackets.split '|'
      name = opts.shift.to_s.strip
      result = case name
        when /^\#\#/ ; '' # invisible comment
        when /^\#/   ;  "<!-- #{CGI.escapeHTML in_brackets} -->"
        when ''      ; '' # no name
        else
          opts = opts.first
          @options = @@options.clone.merge :include_name => name, :include => in_brackets #yuck, need better name (this is raw stuff)

          @configs = Hash.new_from_semicolon_attr_list opts

          @options[:style] = @configs.inject({}) do |styles, pair| key, value = pair
            @options.key?(key.to_sym) ? @options[key.to_sym] = value : styles[key] = value
            styles
          end.map do |style_name,style|
            CGI.escapeHTML "#{style_name}:#{style};"
          end * ''
            
          @name = name
        end
      
      @process_chunk = result if !@name
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

      ( configs = @configs.to_semicolon_attr_list ).blank? or
        configs = "|" + configs
      @text = '{{' + @name.to_s + configs + '}}'
    end

  end
end
