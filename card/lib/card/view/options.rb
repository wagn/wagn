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
            :size
          ]
        ),
        non_standard: ::Set.new(
          [
            :skip_permissions,
            :items,
            :view,
            :hide,
            :show
          ]
        )
      }

      module ClassMethods
        def standard_inheritance_option_keys
          Options.keys[:standard] + [:skip_permissions, :items]
        end

        def option_keys
          @option_keys ||= Options.keys[:standard] + Options.keys[:non_standard]
        end

        def nest_option_keys
          @nest_option_keys ||= (option_keys - [:skip_permissions])
        end
      end

      def load_options
        options
        process_visibility_options
      end

      def options
        @options ||= standard_options_with_inheritance
      end

      def normalized_options
        @normalized_options ||= begin
          options = options_to_hash @raw_options.clone
          options.deep_symbolize_keys!
          options[:view] = original_view
  #          options[:main] = @format.main?
          options # .reject { |_k, v| v.blank? }
        end
      end

      def options_to_hash opts
        case opts
        when Hash  then opts
        when Array then opts[0].merge opts[1]
        when nil   then {}
        else raise Card::Error, "bad view options: #{opts}"
        end
      end

      def main_view_options
        return {} unless main_view?
        @format.main_nest_options
      end

      def foreign_options
        live_options.reject { |key, _value| self.class.option_keys.member? key }
      end

      # run default_X_args
      def live_options
        return @live_options if @live_options
        live_options ||= @format.view_options_with_defaults(
          original_view, normalized_options.clone
        )
        live_options.merge! main_view_options
        @live_options = live_options
      end

      def slot_options
        slot_options = options.clone
        slot_visibility_options slot_options
        slot_options
      end

      def slot_visibility_options slot_options
        [:hide, :show].each do |setting|
          array = viz_hash.keys.select { |k| viz_hash[k] == setting }
          slot_options[setting] = array if array.any?
        end
      end

      def standard_options_with_inheritance
        @options = {}
        self.class.standard_inheritance_option_keys.each do |key|
          value = live_options.delete key
          value ||= @parent.options[key] if @parent
          @options[key] = value if value
        end
        @options
      end

      def items
        options[:items] ||= {}
      end

      Options.keys[:standard].each do |option_key|
        define_method option_key do
          options[option_key]
        end

        define_method "#{option_key}=" do |value|
          options[option_key] = value
        end
      end
    end
  end
end
