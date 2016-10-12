class Card
  class Format
    module Nest
      include Fetch
      include Main
      include Subformat
      include View

      # def voo
      #   # voo = ViewOptions object
      #   @voo ||= Card::ViewOptions.new options
      # end

      def content_nest opts={}
        return opts[:comment] if opts.key? :comment # commented nest
        return main_nest(opts) if main_nest?(opts)
        nest opts[:nest_name], opts
      end

      def nest cardish, options={}, &block
        return "" if nest_invisible?
        nested_card = fetch_nested_card cardish, options
        view, options = interpret_nest_options nested_card, options
        nest_render nested_card, view, options, &block
      end

      def interpret_nest_options nested_card, options
        options.delete_if { |_k, v| v.nil? }
        options[:nest_name] ||= nested_card.name
        view = nest_view options.delete(:view)
        options[:home_view] = [:closed, :edit].member?(view) ? :open : view
        [view, options]
      end

      def interpret_items_directive directive
        return unless directive.is_a? Hash
        @items_directive_view = directive.delete :view
        @items_directive_options = directive
      end

      def nest_view explicit_view
        view = explicit_view || @items_directive_view || default_nest_view
        Card::View.canonicalize view
      end

      def default_nest_view
        :name
      end

      def nest_render nested_card, view, options
        subformat = nest_subformat nested_card, options
        view = subformat.modal_nest_view view
        rendered = count_chars { subformat.optional_render view, options }
        block_given? ? yield(view, rendered) : rendered
      end

      def nest_subformat nested_card, opts
        return self if opts[:nest_name] =~ /^_(self)?$/
        sub = subformat nested_card
        sub.interpret_items_directive opts[:items]
        sub
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

      def main_nest? opts
        opts[:nest_name] == "_main" && show_layout? && @depth.zero?
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
