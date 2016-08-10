class Card
  class Format
    module Nest
      include Fetch
      include Main
      include Subformat
      include View

      def nest name_or_card_or_opts, opts={}
        nested_card = fetch_nested_card name_or_card_or_opts, opts
        opts = name_or_card_or_opts if name_or_card_or_opts.is_a? Hash
        opts[:inc_name] ||= nested_card.name
        nest_card nested_card, opts
      end

      # Main difference compared to #nest is that you can use
      # codename symbols to get nested fields
      # @example
      #   home = Card['home'].format
      #   home.nest :self         # => nest for '*self'
      #   home.field_nest :self   # => nest for 'Home+*self'
      def field_nest field, opts={}
        if field.is_a?(Card)
          nest_card field, opts
        else
          prepare_nest opts.merge(inc_name: card.cardname.field(field))
        end
      end

      def process_nest opts
        opts ||= {}

        if opts.key?(:comment)
          # commented nest
          opts[:comment]
        elsif content_out_of_view?
          ""
        elsif main_nest_within_layout? opts
          main_nest opts
        else
          # standard nest
          count_chars { nest opts }
        end
      end

      # deprecated, use process_nest
      alias_method :prepare_nest, :process_nest

      def nest_card nested_card, opts={}
        # ActiveSupport::Notifications.instrument('card', message:
        # "nest: #{nested_card.name}, #{opts}") do
        opts.delete_if { |_k, v| v.nil? }
        opts.reverse_merge! nest_defaults(nested_card)

        subformat = nest_subformat nested_card, opts
        view = canonicalize_view opts.delete :view
        opts[:home_view] = [:closed, :edit].member?(view) ? :open : view
        # FIXME: special views should be represented in view definitions
        subformat.nest_render view, opts
      end

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

      def content_out_of_view?
        @mode == :closed && @char_count &&
          @char_count > Card.config.max_char_count
      end

      def main_nest_within_layout? opts
        opts[:inc_name] == "_main" && show_layout? && @depth.zero?
      end

      def count_chars
        result = yield
        return result unless @mode == :close && result
        @char_count ||= 0
        @char_count += result.length
        result
      end
    end
  end
end
