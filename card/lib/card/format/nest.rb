class Card
  class Format
    module Nest
      def subformat subcard
        subcard = Card.fetch(subcard, new: {}) if subcard.is_a?(String)
        self.class.new subcard,
                       parent: self, depth: @depth + 1, root: @root,
                       # FIXME: - the following four should not be hard-coded
                       # here.  need a generalized mechanism
                       # for attribute inheritance
                       context_names: @context_names, mode: @mode,
                       mainline: @mainline, form: @form
      end

      def field_subformat field
        field = card.cardname.field(field) unless field.is_a?(Card)
        subformat field
      end

      def field_nest field, opts={}
        if field.is_a?(Card)
          nest field, opts
        else
          prepare_nest opts.merge(inc_name: card.cardname.field(field))
        end
      end

      def with_nest_mode mode
        if (switch_mode = INCLUSION_MODES[mode]) && @mode != switch_mode
          old_mode = @mode
          @mode = switch_mode
          @nest_defaults = nil
        end
        result = yield
        if old_mode
          @nest_defaults = nil
          @mode = old_mode
        end
        result
      end

      def prepare_nest opts
        @char_count ||= 0
        opts ||= {}

        case
        when opts.key?(:comment)
          # commented nest
          opts[:comment]
        when @mode == :closed && @char_count > Card.config.max_char_count
          # move on; content out of view
          ''
        when opts[:inc_name] == '_main' && show_layout? && @depth == 0
          # the main card within a layout
          expand_main opts
        else
          # standard nest
          result = nest fetch_nested_card(opts), opts
          @char_count += result.length if @mode == :closed && result
          result
        end
      end

      def nest nested_card, opts={}
        # ActiveSupport::Notifications.instrument('card', message:
        # "nest: #{nested_card.name}, #{opts}") do
        opts.delete_if { |_k, v| v.nil? }
        opts.reverse_merge! nest_defaults(nested_card)

        sub = nil
        if opts[:inc_name] =~ /^_(self)?$/
          sub = self
        else
          sub = subformat nested_card
          sub.nest_opts = opts[:items] ? opts[:items].clone : {}
        end

        view = canonicalize_view opts.delete :view
        opts[:home_view] = [:closed, :edit].member?(view) ? :open : view
        # FIXME: special views should be represented in view definitions

        view =
          case @mode
          when :edit then
            view_in_edit_mode(view, nested_card)
          when :template then
            :template_rule
          when :closed then
            view_in_closed_mode(view, nested_card)
          else
            view
          end
        sub.optional_render view, opts
      end

      def get_nest_content cardname
        content = params[cardname.to_s.tr('+', '_')]

        # CLEANME This is a hack so plus cards re-populate on failed signups
        p = params['subcards']
        if p && (card_params = p[cardname.to_s])
          content = card_params['content']
        end
        content if content.present? # returns nil for empty string
      end

      def fetch_nested_card options
        Card.fetch options[:inc_name], new: nest_new_args(options)
      end

      def nest_new_args options
        args = { name: options[:inc_name], type: options[:type], supercard: card }
        args.delete(:supercard) if options[:inc_name].strip.blank?
        # special case.  gets absolutized incorrectly. fix in smartname?
        if options[:inc_name] =~ /^_main\+/
          # FIXME: this is a rather hacky (and untested) way to get @superleft
          # to work on new cards named _main+whatever
          args[:name] = args[:name].gsub(/^_main\+/, '+')
          args[:supercard] = root.card
        end
        if (content = get_nest_content options[:inc_name])
          args[:content] = content
        end
        args
      end

      def wrap_main content
        content # no wrapping in base format
      end

      def nest_defaults nested_card
        @nest_defaults ||= begin
          defaults = get_nest_defaults(nested_card).clone
          defaults.merge! @nest_opts if @nest_opts
          defaults
        end
      end

      def get_nest_defaults _nested_card
        { view: :name }
      end

      protected

      def expand_main opts
        opts.merge! root.main_opts if root.main_opts
        legacy_main_opts_tweaks! opts

        with_nest_mode :normal do
          @mainline = true
          result = wrap_main nest(root.card, opts)
          @mainline = false
          result
        end
      end

      def legacy_main_opts_tweaks! opts
        if (val = params[:size]) && val.present?
          opts[:size] = val.to_sym
        end

        if (val = params[:item]) && val.present?
          opts[:items] = (opts[:items] || {}).reverse_merge view: val.to_sym
        end
      end

      def view_in_edit_mode homeview, nested_card
        not_in_form =
          Card::Format.perms[homeview] == :none || # view configured not to keep
          # in form
          nested_card.structure || # not yet nesting structures
          nested_card.key.blank? # eg {{_self|type}} on new cards

        not_in_form ? :blank : :edit_in_form
      end

      def view_in_closed_mode homeview, nested_card
        approved_view = Card::Format.closed[homeview]
        case
        when approved_view == true then
          homeview
        when Card::Format.error_code[homeview] then
          homeview
        when approved_view then
          approved_view
        when !nested_card.known? then
          :closed_missing
        else
          :closed_content
        end
      end
    end
  end
end
