class Card
  class View
    # normalizes and manages standard view options
    module Options
      # option values are strings unless otherwise noted
      @keymap = {
        nest: [
          :view,          # view to render
          :show,          # render these views when optional
          :hide,          # do not render these views when optional
          :nest_name,     # name as used in nest
          :nest_syntax    # full nest syntax
        ],
        # note: show/hide can be single view (Symbol), list of views (Array),
        # or comma separated views (String)
        heir: [
          :main,           # format object is page's "main" object (Boolean)
          :home_view,      # view for slot to return to when no view specified
          :edit_structure  # use a different structure for editing (Array)
        ],
        both: [
          :help, # cue text when editing
          :structure, # overrides the content of the card
          :title, # overrides the name of the card
          :variant, # override the canonical version of the name with
          #                a different variant
          :editor, # inline_nests makes a form within standard content
          #                (Symbol)
          :type, # set the default type of new cards
          :size, # set an image size
          :params, # parameters for add button.  deprecate?
          :items, # options for items (Hash)
          :cache # change view cache behaviour
        #                (Symbol<:always, :standard, :never>)
        ],
        none: [
          :skip_perms,  # do not check permissions for this view (Boolean)
          :main_view
        ]   # this is main view of page (Boolean)
      }

      class << self
        attr_reader :keymap

        # all standard option keys
        def all_keys
          @all_keys ||= keymap.each_with_object([]) { |(_k, v), a| a.push(*v) }
        end

        # keys whose values can be set by Wagneers in card nests
        def nest_keys
          @nest_keys ||= ::Set.new(keymap[:both]) + keymap[:nest]
        end

        # keys that follow simple standard inheritance pattern from parent views
        def heir_keys
          @heir_keys ||= ::Set.new(keymap[:both]) + keymap[:heir]
        end

        def accessible_keys
          heir_keys + [:nest_name, :nest_syntax] - [:items]
        end

        def define_getter option_key
          define_method option_key do
            norm_method = "normalize_#{option_key}"
            value = live_options[option_key]
            try(norm_method, value) || value
          end
        end

        def define_setter option_key
          define_method "#{option_key}=" do |value|
            live_options[option_key] = value
          end
        end
      end

      # There are two primary options hashes:
      # - @normalized_options are determined upon initialization and do not
      #   change after that.
      # - @live_options are created during the "process" phase, and they can be
      #   altered via the "voo" API at any time

      attr_reader :normalized_options

      def live_options
        @live_options ||= process_live_options
      end

      # The following methods comprise the primary voo API.  They allow
      # developers to read and write options dynamically

      def items
        live_options[:items] ||= {}
      end

      accessible_keys.each do |option_key|
        define_getter option_key
        define_setter option_key
      end

      def normalize_editor value
        value && value.to_sym
      end

      def normalize_cache value
        value && value.to_sym
      end

      # options to be used in data attributes of card slots (normalized options
      # with standard keys)
      def slot_options
        normalized_options.select { |k, _v| Options.all_keys.include? k }
      end

      def closest_live_option key
        if live_options.key? key
          live_options[key]
        else
          (parent && parent.closest_live_option(key)) ||
            (format.parent && format.parent.voo &&
              format.parent.voo.closest_live_option(key))
        end
      end

      private

      # option normalization includes standardizing options into a hash with
      # symbols as keys, managing standard view inheritance, and special
      # handling for main_views.
      def normalize_options
        @normalized_options = opts = options_to_hash @raw_options.clone
        opts[:view] = @raw_view
        inherit_from_parent if parent
        opts[:main] = true if format.main?
        @optional = opts.delete(:optional) || false
        opts
      end

      # typically options are already a hash.  this also handles an array of
      # hashes and nil.
      def options_to_hash opts
        case opts
        when Hash  then opts
        when Array then opts[0].merge opts[1]
        when nil   then {}
        else raise Card::Error, "bad view options: #{opts}"
        end.deep_symbolize_keys!
      end

      # standard inheritance from parent view object
      def inherit_from_parent
        Options.heir_keys.each do |key|
          parent_value = parent.live_options[key]
          normalized_options[key] ||= parent_value if parent_value
        end
      end

      def process_live_options
        opts = @live_options = normalized_options.clone
        opts.merge! format.main_nest_options if opts[:main_view]
        # main_view is a live_option because it is important that it NOT be
        # locked in the stub.  Otherwise the main card can only show one view.
        process_default_options
        opts
      end

      # This method triggers the default_X_args methods which can alter the
      # @live_options hash both directly and indirectly (via the voo API)
      def process_default_options
        format.view_options_with_defaults requested_view, live_options
      end

      # "foreign" options are non-standard options.  They're allowed, but they
      # prevent independent caching (and thus stubbing)
      def foreign_options opts
        opts.reject { |k, _v| Options.all_keys.include? k }
      end

      def foreign_normalized_options
        @foreign_normalize_options ||= foreign_options normalized_options
      end

      def foreign_live_options
        foreign_options live_options
      end
    end
  end
end
