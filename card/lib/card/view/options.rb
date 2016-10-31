class Card
  class View
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

      def options
        @options ||= standard_options_with_inheritance
      end

      def standard_options_with_inheritance
        @options = prep_options.select do |k, _v|
          self.class.option_keys.member? k
        end
        inherit_from_parent if @parent
        @options.reject! { |_k, v| v.blank? }
        @options
      end

      def inherit_from_parent
        self.class.standard_inheritance_option_keys.each do |key|
          @options[key] ||= @parent.options[key]
        end
      end

      def normalized_options
        @normalized_options ||= normalize_options!
      end

      def normalize_options!
        options = options_to_hash @raw_options.clone
        options.deep_symbolize_keys!
        handle_main_options options
        options[:view] ||= @raw_view
        options
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
        end
      end

      def foreign_options
        @foreign_options ||= prep_options.reject do |key, _value|
          self.class.option_keys.member? key
        end
      end

      def prep_options
        @prep_options ||= prep_options!
      end

      def prep_options!
        @prep_options = normalized_options.clone
        process_default_options
        @prep_options
      end

      def process_default_options
        @format.view_options_with_defaults requested_view, @prep_options
      end

      def slot_options
        normalized_options.select { |k, _v| self.class.option_keys.include? k }
      end

      def slot_visibility_options slot_options
        [:hide, :show].each do |setting|
          array = viz_hash.keys.select { |k| viz_hash[k] == setting }
          slot_options[setting] = array.join "," if array.any?
        end
      end

      def items
        options[:items] ||= {}
      end

      Options.keys[:standard].each do |option_key|
        define_method option_key do
          @prepared ? options[option_key] : prep_options[option_key]
        end

        define_method "#{option_key}=" do |value|
          if @prepared
            options[option_key] = value
          else
            prep_options[option_key] = value
          end
        end
      end
    end
  end
end
