class Card
  class View

    module Visibility
      def hide? view=nil
        !show? view
      end

      def show? view=nil
        if view.nil?
          return true unless optional?
          view = requested
        end
        viz_hash[view] == :show
      end

      def show! *views
        viz views, :show
      end

      def hide! *views
        viz views, :hide
      end

      def optional?
        return @optional unless @optional.nil?
        process_cardist_visibility
        @optional = detect_if_optional
      end

      def viz views, setting, force=false
        Array.wrap(views).each do |view|
          next if !force && viz_hash[view]
          viz_hash[view] = setting
        end
      end

      def detect_if_optional
        if (setting = pre_options.delete :optional)
          viz requested, setting
          setting
        else
          false
        end
      end

      def viz_hash
        @viz_hash ||= {}
      end

      def visibility
        @visibility ||= (viz_hash[requested] || :show)
      end

      def process_cardist_visibility
        [:hide, :show].each do |setting|
          list = visible_view_list(pre_options[setting])
          viz list, setting, force=true
        end
      end

      def visible_view_list val
        case val
        when NilClass then []
        when Array    then val
        when String   then val.split(/[\s,]+/)
        when Symbol   then [val.to_s]
        else raise Card::Error, "bad show/hide argument: #{val}"
        end.map { |view| View.canonicalize view }
      end
    end
  end
end
