class Card
  class View
    #
    module Options
      def self.keys
        @keys
      end

      @keys = {
        standard: ::Set.new(
          [
            :nest_name,   # name as used in nest
            :nest_syntax, # full nest syntax

            :structure,   # overrides the content of the card
            :title,       # overrides the name of the card
            :variant,     # override the canonical version of the name with
            #               a different variant
            :type,        # set the default type of new cards
            :size,        # set an image size

            :params,      # TODO: let's discuss this one!

            #                    # These three are not
            :home_view,
            :skip_permissions,
            :main
          ]
        ),
        non_standard: ::Set.new(
          [
            :items,
            :view,
            :hide,
            :show,
            :main_view
          ]
        )
      }

      module ClassMethods
        def standard_inheritance_option_keys
          @standard_inheritance_option_keys ||=
            Options.keys[:standard] + [:items]
        end

        def option_keys
          @option_keys ||= Options.keys[:standard] + Options.keys[:non_standard]
          # Option.keys.each_with_object([]) { |(k, v), array| array + values }
        end

        def nest_option_keys
          @nest_option_keys ||=
            (option_keys - [:skip_permissions, :main, :main_view, :home_view])
        end
      end

      def normalized_options
        @normalized_options
      end

      def normalize_options!
        @normalized_options = opts = options_to_hash @raw_options.clone
        opts[:view] = @raw_view
        inherit_from_parent if parent
        @format.main? ? opts[:main] = true : opts.delete(:main)
        @optional = opts.delete(:optional) || false
        opts
      end

      def options_to_hash opts
        case opts
        when Hash  then opts
        when Array then opts[0].merge opts[1]
        when nil   then {}
        else raise Card::Error, "bad view options: #{opts}"
        end.deep_symbolize_keys!
      end

      def live_options
        @live_options ||= process_live_options!
      end

      def process_live_options!
        opts = @live_options = normalized_options.clone
        opts.merge! @format.main_nest_options if opts[:main_view]
        process_default_options
        opts
      end

      def inherit_from_parent
        self.class.standard_inheritance_option_keys.each do |key|
          parent_value = parent.live_options[key]
          normalized_options[key] ||= parent_value if parent_value
        end
      end

      def process_default_options
        @format.view_options_with_defaults requested_view, @live_options
      end

      def foreign_normalized_options
        @foreign_normalize_options ||= foreign_options normalized_options
      end

      def foreign_live_options
        foreign_options live_options
      end

      def foreign_options opts
        opts.reject do |key, _value|
          self.class.option_keys.member? key
        end
      end

      def slot_options
        normalized_options.select { |k, _v| self.class.option_keys.include? k }
      end

      def items
        live_options[:items] ||= {}
      end

      Options.keys[:standard].each do |option_key|
        define_method option_key do
          live_options[option_key]
        end

        define_method "#{option_key}=" do |value|
          live_options[option_key] = value
        end
      end
    end
  end
end
