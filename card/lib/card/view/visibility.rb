class Card
  class View
    module Visibility
      def hide?
        !show?
      end

      def show?
        return true unless optional?
        visibility_config == :show
      end

      def optional?
        @optional ||= pre_options.delete :optional
      end

      def raw_visibility_config
        @raw_visibility_config ||= pre_options["optional_#{requested}".to_sym]
      end

      def visibility_config
        @visibility_config ||= (forced_visibility     ||
                                wagneered_visibility  ||
                                raw_visibility_config ||
                                default_visibility    ||
                                :show)
      end

      def forced_visibility
        case raw_visibility_config
        when :always then :show
        when :never  then :hide
        end
      end

      def default_visibility
        @default_visibility ||= pre_options.delete :default_visibility
      end

      def wagneered_visibility
        [:show, :hide].each do |setting|
          view_list = visible_view_list pre_options[setting]
          return setting if view_list.member? requested
        end
        nil
      end

      def visible_view_list val
        case val
        when NilClass then []
        when Array    then val
        when String   then val.split(/[\s,]+/)
        else raise Card::Error, "bad show/hide argument: #{val}"
        end.map { |view| View.canonicalize view }
      end
    end
  end
end
