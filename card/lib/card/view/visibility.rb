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
#          update_viz_arrays view, setting
        end
      end

      # def update_viz_arrays view, setting
      #   other = setting == :hide ? :show : :hide
      #   options[setting] ||= []
      #   options[setting].push view unless options[setting].include? view
      #   options[other].delete view if options[other]
      # end

      def detect_if_optional
        if (setting = live_args.delete :optional)
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

      def process_visibility_options
        @viz_hash = @parent_voo ? @parent_voo.viz_hash.clone : {}
        process_visibility live_args
      end

      def update_visibility_options
        [:hide, :show].each do |setting|
          options[setting] = viz_hash.keys.select do |k|
            viz_hash[k] == setting
          end.sort
        end
      end

      def process_visibility arg_hash
        [:hide, :show].each do |setting|
          list = viz_view_list arg_hash[setting]
          viz list, setting, force=true
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
