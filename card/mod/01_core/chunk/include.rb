# -*- encoding : utf-8 -*-

require_dependency File.expand_path( '../reference', __FILE__ )

module Card::Chunk
  class Include < Reference
    cattr_reader :options
    @@options = ::Set.new [ :inc_name, :inc_syntax, :view, :items, :type, :size, :title, :hide, :show, :structure ]
    attr_reader :options

    Card::Chunk.register_class self, {
      :prefix_re => '\\{\\{',
      :full_re   =>  /^\{\{([^\}]*)\}\}/,
      :idx_char  => '{'
    }

    def interpret match, content
      in_brackets = strip_tags match[1]
#      warn "in_brackets = #{in_brackets}"
      name, @opt_lists = in_brackets.split '|', 2
      name = name.to_s.strip
      result = case name
        when /^\#\#/ ; '' # invisible comment
        when /^\#/   ; "<!-- #{CGI.escapeHTML in_brackets} -->"
#        when /^\s*$/ ; '' # no name
        else
          @options = @opt_lists.to_s.split('|').reverse.inject(nil) do |prev_level, level_options|
            process_options level_options, prev_level
          end || {}
          @options.merge! :inc_name => name, :inc_syntax => in_brackets
          @name = name
        end

      @process_chunk = result if !@name
    end

    def strip_tags string
      #note: not using ActionView's strip_tags here because this needs to be super fast.
      string.gsub /\<[^\>]*\>/, ''
    end

    def process_options list_string, items
      hash = {}
      style_hash = {}
      hash[:items] = items unless items.nil?
      Hash.new_from_semicolon_attr_list( list_string ).each do |key, value|
        key = key.to_sym
        if key==:item
          hash[:items] ||= {}
          hash[:items][:view] = value
        elsif @@options.include? key
          hash[key] = value
        else
          style_hash[key] = value
        end
      end

      if !style_hash.empty?
        hash[:style] = style_hash.map { |key, value| CGI.escapeHTML "#{key}:#{value};" } * ''
      end
      hash
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
    
    def explicit_view= view
      unless @options[:view] #could check to make sure it's not already the default...
        if @text =~ /\|/
          @text.sub! '|', "|#{view};"
        else
          @text.sub! '}}', "|#{view}}}"
        end
      end
    end

  end
end
