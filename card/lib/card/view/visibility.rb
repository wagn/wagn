class Card
  class View

    module Visibility
      def hide? view
        viz_hash[view] == :hide
      end

      def show? view
        !hide? view
      end

      def show! *views
        viz views, :show, true
      end

      def hide! *views
        viz views, :hide, true
      end

      def show *views
        viz views, :show
      end

      def hide *views
        viz views, :hide
      end

      def optional?
        return @optional unless @optional.nil?
        @optional = detect_if_optional
      end

      def viz views, setting, force=false
        Array.wrap(views).each do |view|
          next if !force && viz_hash[view]
          viz_hash[view] = setting
        end
      end

      def detect_if_optional
        if (setting = live_options.delete :optional)
          viz requested_view, setting
          setting
        else
          false
        end
      end

      # eg  { toggle: :hide }
      def viz_hash
        @viz_hash ||= {}
      end

      def visibility
        @visibility ||= (viz_hash[requested_view] || :show)
      end

      def process_visibility_options
        viz_hash.reverse_merge! parent.viz_hash if parent
        process_visibility live_options
      end

      def process_visibility arg_hash
        [:hide, :show].each do |setting|
          list = viz_view_list arg_hash[setting]
          viz list, setting, true
        end
      end

      def viz_view_list val
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
