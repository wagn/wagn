class Card
  class Format
    module Nest
      include Fetch
      include Main
      include Subformat
      include View

      def nest cardish, options={}
        return "" if nest_invisible?
        # nested_card = Card.cardish cardish
        nested_card = fetch_nested_card cardish

        view = standardize_nest_options nested_card, options
        nest_render nested_card, view, options
      end

      def standardize_nest_options nested_card, options
        options.delete_if { |_k, v| v.nil? }
        options.reverse_merge! nest_defaults(nested_card)

        options[:nest_name] ||= nested_card.name
        view = Card::View.canonicalize options.delete(:view)

        options[:home_view] = [:closed, :edit].member?(view) ? :open : view
        view
      end

      def nest_render nested_card, view, options
        subformat = nest_subformat nested_card, options
        view = subformat.nest_view view
        count_chars do
          subformat.optional_render view, options
        end
      end

      def content_nest opts={}
        return opts[:comment] if opts.key? :comment # commented nest
        return main_nest(opts) if main_nest?(opts)
        nest opts[:nest_name], opts
      end

      # Main difference compared to #nest is that you can use
      # codename symbols to get nested fields
      # @example
      #   home = Card['home'].format
      #   home.nest :self         # => nest for '*self'
      #   home.field_nest :self   # => nest for 'Home+*self'
      def field_nest field, view, opts={}
        field = card.cardname.field(field) unless field.is_a? Card
        nest field, view, opts
      end

      # opts[:home_view] = [:closed, :edit].member?(view) ? :open : view
      # FIXME: special views should be represented in view definitions

      def nest_defaults nested_card
        @nest_defaults ||= begin
          defaults = get_nest_defaults(nested_card).clone
          defaults.merge! @nest_opts if @nest_opts
          defaults
        end
      end

      def get_nest_defaults _nested_card
        { view: :name }
      end

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
