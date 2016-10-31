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

            :structure,
            :type,
            :title,
            :variant,
            :params,
            :home_view,
            :size,

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
          Options.keys[:standard] + [:items]
        end

        def option_keys
          @option_keys ||= Options.keys[:standard] + Options.keys[:non_standard]
        end

        def nest_option_keys
          @nest_option_keys ||=
            (option_keys - [:skip_permissions, :main, :main_view])
        end
      end

      def normalized_options
        @normalized_options
      end

      def normalize_options!
        @normalized_options = opts = options_to_hash @raw_options.clone
        opts[:view] = @raw_view
        handle_main_options opts
        inherit_from_parent if parent
        detect_if_optional opts
        opts.reject! { |_k, v| v.blank? }
        opts
      end

      def detect_if_optional opts
        @optional = opts.delete(:optional) || false
        viz requested_view, @optional if @optional
      end

      def handle_main_options opts
        opts[:main] = @format.main?
        opts.merge! @format.main_nest_options if opts[:main_view]
      end

      def options_to_hash opts
        case opts
        when Hash  then opts
        when Array then opts[0].merge opts[1]
        when nil   then {}
        else raise Card::Error, "bad view options: #{opts}"
        end.deep_symbolize_keys!
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

      def live_options
        @live_options ||= process_live_options!
      end

      def process_live_options!
        @live_options = normalized_options.clone
        process_default_options
        @live_options
      end

      def inherit_from_parent
        self.class.standard_inheritance_option_keys.each do |key|
          normalized_options[key] ||= parent.live_options[key]
        end
      end

      def process_default_options
        @format.view_options_with_defaults requested_view, @live_options
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
