class Card
  class View
    # manages showing and hiding optional view renders
    module Visibility
      # tracks show/hide value for each view with an explicit setting
      # eg  { toggle: :hide }
      def viz_hash
        @viz_hash ||= {}
      end

      # test methods

      def hide? view
        viz_hash[view] == :hide
      end

      def show? view
        !hide? view
      end

      # write methods

      def show *views
        viz views, :show
      end

      def hide *views
        viz views, :hide
      end

      # force write methods

      def show! *views
        viz views, :show, true
      end

      def hide! *views
        viz views, :hide, true
      end

      # advanced write method
      VIZ_SETTING = { show: :show, true => :show,
                      hide: :hide, false => :hide, nil => :hide }

      def viz views, setting, force=false
        Array.wrap(views).each do |view|
          view = view.to_sym
          next if !force && viz_hash[view]
          viz_hash[view] = VIZ_SETTING[setting]
        end
      end

      def visible? view
        unless viz_hash[view]
          viz view, yield
        end
        show? view
      end

      # test whether main_view is optional
      # (@optional is set in normalize_options
      def optional?
        return @optional unless @optional.nil?
        @optional = detect_if_optional
      end

      # translate raw hide, show options (which can be strings, symbols,
      # arrays, etc)
      def process_visibility_options
        viz_hash.reverse_merge! parent.viz_hash if parent
        process_visibility live_options
        viz requested_view, @optional if @optional && !viz_hash[requested_view]
      end

      # takes an options_hash and processes it to update viz_hash
      def process_visibility options_hash
        [:hide, :show].each do |setting|
          list = viz_view_list options_hash.delete(setting)
          viz list, setting, true
        end
      end

      # translated show/hide setting into an array of views
      def viz_view_list val
        case val
        when NilClass then []
        when Array    then val
        when String   then val.split(/[\s,]+/)
        when Symbol   then [val]
        else raise Card::Error, "bad show/hide argument: #{val}"
        end.map { |view| View.canonicalize view }
      end
    end
  end
end
