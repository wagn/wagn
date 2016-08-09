# -*- encoding : utf-8 -*-

require_dependency File.expand_path("../reference", __FILE__)

module Card::Content::Chunk
  class Include < Reference
    cattr_reader :options
    @@options = ::Set.new [
      :inc_name,   # name as used in nest
      :inc_syntax, # full nest syntax
      :items,      # handles pipe-based recursion

      # _conventional options_
      :view,       #
      :type,       #
      :size,       # images only
      :title,      #
      :hide,       # affects optional rendering
      :show,       # affects optional rendering
      :structure,  # override raw_content
      :params,     #
      :variant     #
    ]
    attr_reader :options
    DEFAULT_OPTION = :view # a value without a key is interpreted as view

    Card::Content::Chunk.register_class(
      self, prefix_re: '\\{\\{',
            full_re:    /^\{\{([^\}]*)\}\}/,
            idx_char:  "{"
    )

    def interpret match, _content
      in_brackets = strip_tags match[1]
      name, @opt_lists = in_brackets.split "|", 2
      name = name.to_s.strip
      if name =~ /^\#/
        @process_chunk = name =~ /^\#\#/ ? "" : visible_comment(in_brackets)
      else
        @options = interpret_options
        @options[:inc_name] = name
        @options[:inc_syntax] = in_brackets
        @name = name
      end
    end

    def strip_tags string
      # note: not using ActionView's strip_tags here
      # because this needs to be super fast.
      string.gsub(/\<[^\>]*\>/, "")
    end

    def visible_comment message
      "<!-- #{CGI.escapeHTML message} -->"
    end

    def interpret_options
      raw_options = @opt_lists.to_s.split("|").reverse
      raw_options.inject(nil) do |prev_level, level_options|
        interpret_piped_options level_options, prev_level
      end || {}
    end

    def interpret_piped_options list_string, items
      options_hash = items.nil? ? {} : { items: items }
      style_hash = {}
      option_string_to_hash list_string, options_hash, style_hash
      style_hash_to_string options_hash, style_hash
      options_hash
    end

    def option_string_to_hash list_string, options_hash, style_hash
      each_option(list_string) do |key, value|
        key = key.to_sym
        if key == :item
          options_hash[:items] ||= {}
          options_hash[:items][:view] = value
        elsif @@options.include? key
          options_hash[key] = value
        else
          style_hash[key] = value
        end
      end
    end

    def style_hash_to_string options_hash, style_hash
      return if style_hash.empty?
      options_hash[:style] = style_hash.map do |key, value|
        CGI.escapeHTML "#{key}:#{value};"
      end * ""
    end

    def inspect
      "<##{self.class}:n[#{@name}] p[#{@process_chunk}] txt:#{@text}>"
    end

    def process_chunk
      return @process_chunk if @process_chunk

      referee_name
      @processed = yield @options
      # this is not necessarily text, sometimes objects for json
    end

    def replace_reference old_name, new_name
      replace_name_reference old_name, new_name
      nest_body = [@name.to_s, @opt_lists].compact * "|"
      @text = "{{#{nest_body}}}"
    end

    def explicit_view= view
      return if @options[:view]
      # could check to make sure it's not already the default...
      if @text =~ /\|/
        @text.sub! "|", "|#{view};"
      else
        @text.sub! "}}", "|#{view}}}"
      end
    end

    private

    def each_option attr_string
      return if attr_string.blank?
      attr_string.strip.split(";").each do |pair|
        value, key = pair.split(":").reverse
        key ||= self.class::DEFAULT_OPTION.to_s
        yield key.strip, value.strip
      end
    end
  end
end
