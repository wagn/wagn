class Card
  class Format
    module Nest
      include Fetch
      include Main
      include Subformat
      include View

      # nested by another card's content
      # (as opposed to a direct API nest)
      def content_nest opts={}
        return opts[:comment] if opts.key? :comment # commented nest
        nest_name = opts[:nest_name]
        return main_nest(opts) if main_nest?(nest_name)
        nest nest_name, opts
      end

      def nest cardish, options={}, &block
        return "" if nest_invisible?
        nested_card = fetch_nested_card cardish, options
        view, options = interpret_nest_options nested_card, options
        nest_render nested_card, view, options, &block
      end

      def interpret_nest_options nested_card, options
        options[:nest_name] ||= nested_card.name
        view = options[:view] || implicit_nest_view
        view = Card::View.canonicalize view

        # FIXME: should handle in closed / edit view definitions
        options[:home_view] ||= [:closed, :edit].member?(view) ? :open : view

        [view, options]
      end

      def implicit_nest_view
        view = voo_items_view || default_nest_view
        Card::View.canonicalize view
      end

      def default_nest_view
        :name
      end

      def nest_render nested_card, view, options
        subformat = nest_subformat nested_card, options, view
        view = subformat.modal_nest_view view
        rendered = count_chars { subformat.optional_render view, options }
        block_given? ? yield(rendered, view) : rendered
      end

      def nest_subformat nested_card, opts, view
        return self if reuse_format? opts[:nest_name], view
        sub = subformat nested_card
        sub.main! if opts[:main]
        sub
      end

      def reuse_format? nest_name, view
        nest_name =~ /^_(self)?$/ &&
          card.context_card == card &&
          !nest_recursion_risk?(view)
      end

      def nest_recursion_risk? view
        content_view?(view) && voo.structure
      end

      def content_view? view
        # TODO: this should be specified in view definition
        [
          :core, :content, :titled, :open, :closed, :open_content
        ].member? view.to_sym
      end

      # Main difference compared to #nest is that you can use
      # codename symbols to get nested fields
      # @example
      #   home = Card['home'].format
      #   home.nest :self         # => nest for '*self'
      #   home.field_nest :self   # => nest for 'Home+*self'
      def field_nest field, opts={}
        field = card.cardname.field(field) unless field.is_a? Card
        nest field, opts
      end

      # opts[:home_view] = [:closed, :edit].member?(view) ? :open : view
      # FIXME: special views should be represented in view definitions

      private

      def nest_invisible?
        @mode == :closed && @char_count && @char_count > max_char_count
      end

      def count_chars
        result = yield
        return result unless @mode == :closed && result
        @char_count ||= 0
        @char_count += result.length
        result
      end

      def max_depth
        Card.config.max_depth
      end

      def max_char_count
        Card.config.max_char_count
      end
    end
  end
end
