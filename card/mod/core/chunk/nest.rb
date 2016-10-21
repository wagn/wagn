# -*- encoding : utf-8 -*-

require_dependency File.expand_path("../reference", __FILE__)

class Card
  class Content
    module Chunk
      # Handler for nest chunks: {{example}}
      class Nest < Reference
        attr_reader :options
        DEFAULT_OPTION = :view # a value without a key is interpreted as view

        Chunk.register_class(self, prefix_re: '\\{\\{',
                                   full_re:    /^\{\{([^\}]*)\}\}/,
                                   idx_char:  "{")

        def interpret match, _content
          in_brackets = strip_tags match[1]
          name, @opt_lists = in_brackets.split "|", 2
          name = name.to_s.strip
          if name =~ /^\#/
            @process_chunk = name =~ /^\#\#/ ? "" : visible_comment(in_brackets)
          else
            @options = interpret_options.merge nest_name: name,
                                               nest_syntax: in_brackets
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
          option_string_to_hash list_string, options_hash
          options_hash
        end

        def option_string_to_hash list_string, options_hash
          each_option(list_string) do |key, value|
            key = key.to_sym
            if key == :item
              options_hash[:items] ||= {}
              options_hash[:items][:view] = value
            elsif Card::View.options.include? key
              options_hash[key] = value
              # else
              # handle other keys
            end
          end
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
  end
end
