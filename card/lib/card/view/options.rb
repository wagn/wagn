class Card
  class View
    # means for managing standard view options
    module Options
      @keymap = {
        nest_and_inherit: [
          :nest_name,   # name as used in nest
          :nest_syntax, # full nest syntax
          :structure,   # overrides the content of the card
          :title,       # overrides the name of the card
          :variant,     # override the canonical version of the name with
          #             # a different variant
          :type,        # set the default type of new cards
          :size,        # set an image size
          :params,      # TODO: let's discuss this one!
          :items
        ],
        nest: [
          :view,
          :hide,
          :show
        ],
        inherit: [
          :main,
          :home_view
        ],
        other: [
          :skip_permissions,
          :main_view
        ]
      }

      class << self
        attr_reader :keymap

        def all_keys
          @all_keys ||= keymap.each_with_object([]) { |(_k, v), a| a.push(*v) }
        end

        def heir_keys
          @heir_keys ||= ::Set.new(keymap[:nest_and_inherit]) + keymap[:inherit]
        end

        def nest_keys
          @nest_keys ||= ::Set.new(keymap[:nest_and_inherit]) + keymap[:nest]
        end
      end

      def normalized_options
        @normalized_options
      end

      def normalize_options!
        @normalized_options = opts = options_to_hash @raw_options.clone
        opts[:view] = @raw_view
        inherit_from_parent if parent
        format.main? ? opts[:main] = true : opts.delete(:main)
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
        opts.merge! format.main_nest_options if opts[:main_view]
        process_default_options
        opts
      end

      def inherit_from_parent
        Options.heir_keys.each do |key|
          parent_value = parent.live_options[key]
          normalized_options[key] ||= parent_value if parent_value
        end
      end

      def process_default_options
        format.view_options_with_defaults requested_view, live_options
      end

      def foreign_normalized_options
        @foreign_normalize_options ||= foreign_options normalized_options
      end

      def foreign_live_options
        foreign_options live_options
      end

      def foreign_options opts
        opts.reject { |k, _v| Options.all_keys.include? k }
      end

      def slot_options
        normalized_options.select { |k, _v| Options.all_keys.include? k }
      end

      def items
        live_options[:items] ||= {}
      end

      (heir_keys - [:items]).each do |option_key|
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
