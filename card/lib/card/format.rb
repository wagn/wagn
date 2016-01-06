# -*- encoding : utf-8 -*-

class Card
  class Format
    include Card::Location

    DEPRECATED_VIEWS = { view: :open, card: :open, line: :closed,
                         bare: :core, naked: :core }
    INCLUSION_MODES  = { closed: :closed, closed_content: :closed, edit: :edit,
                         layout: :layout, new: :edit, setup: :edit,
                         normal: :normal, template: :template }
    # FIXME: should be set in views

    cattr_accessor :ajax_call, :registered
    [:perms, :denial, :closed, :error_code, :view_tags, :aliases
    ].each do |accessor_name|
      cattr_accessor accessor_name
      send "#{accessor_name}=", {}
    end

    attr_reader :card, :root, :parent, :main_opts
    attr_accessor :form, :error_status, :inclusion_opts

    class << self
      @@registered = []

      def register format
        @@registered << format.to_s
      end

      def format_class_name format
        format = format.to_s
        format = '' if format == 'base'
        format = @@aliases[format] if @@aliases[format]
        "#{format.camelize}Format"
      end

      def extract_class_vars view, opts
        return unless opts.present?
        [:perms, :error_code, :denial, :closed].each do |varname|
          class_var = send varname
          class_var[view] = opts.delete(varname) if opts[varname]
        end
        extract_view_tags view, opts
      end

      def extract_view_tags view, opts
        tags = opts.delete :tags
        return unless tags
        Array.wrap(tags).each do |tag|
          view_tags[view] ||= {}
          view_tags[view][tag] = true
        end
      end

      def new card, opts={}
        if self != Format
          super
        else
          format = opts[:format] || :html
          klass = Card.const_get format_class_name(format)
          self == klass ? super : klass.new(card, opts)
        end
      end

      def tagged view, tag
        return unless view && tag && (view_tags = @@view_tags[view.to_sym])
        view_tags[tag.to_sym]
      end

      def format_ancestry
        ancestry = [self]
        unless self == Card::Format
          ancestry = ancestry + superclass.format_ancestry
        end
        ancestry
      end

      def max_depth
        Card.config.max_depth
      end
    end

    # ~~~~~ INSTANCE METHODS

    def initialize card, opts={}
      unless (@card = card)
        raise Card::Error, 'format initialized without card'
      end
      opts.each do |key, value|
        instance_variable_set "@#{key}", value
      end

      @mode ||= :normal
      @root ||= self
      @depth ||= 0

      @context_names = get_context_names
      include_set_format_modules
      self
    end

    def get_context_names
      case
      when @context_names
        part_keys = @card.cardname.part_names.map &:key
        @context_names.reject { |n| !part_keys.include? n.key }
      when params[:slot]
        context_name_list = params[:slot][:name_context].to_s
        context_name_list.split(',').map &:to_name
      else
        []
      end
    end

    def include_set_format_modules
      self.class.format_ancestry.reverse_each do |klass|
        card.set_format_modules(klass).each do |m|
          singleton_class.send :include, m
        end
      end
    end

    def inclusion_defaults nested_card
      @inclusion_defaults ||= begin
        defaults = get_inclusion_defaults(nested_card).clone
        defaults.merge! @inclusion_opts if @inclusion_opts
        defaults
      end
    end

    def get_inclusion_defaults _nested_card
      { view: :name }
    end

    def params
      Env.params
    end

    def controller
      Env[:controller] ||= CardController.new
    end

    def session
      Env.session
    end

    def showname title=nil
      if title
        title.to_name.to_absolute_name(card.cardname).to_show *@context_names
      else
        @showname ||= card.cardname.to_show *@context_names
      end
    end

    def with_name_context name
      old_context = @context_names
      add_name_context name
      result = yield
      @context_names = old_context
      result
    end

    def main?
      @depth == 0
    end

    def focal? # meaning the current card is the requested card
      if Env.ajax?
        @depth == 0
      else
        main?
      end
    end

    def template
      @template ||= begin
        c = controller
        t = ActionView::Base.new c.class.view_paths, { _routes: c._routes }, c
        t.extend c.class._helpers
        t
      end
    end

    def method_missing method, *opts, &proc
      if method =~ /(_)?(optional_)?render(_(\w+))?/
        view = $3 ? $4 : opts.shift
        args = opts[0] ? opts.shift.clone : {}
        args.merge!(optional: true, default_visibility: opts.shift) if $2
        args[:skip_permissions] = true if $1
        render view, args
      else
        proc = proc { |*a| raw yield *a } if proc
        response = root.template.send method, *opts, &proc
        response.is_a?(String) ? root.template.raw(response) : response
      end
    end

    #
    # ---------- Rendering ------------
    #

    def render view, args={}
      view = canonicalize_view view
      return if hidden_view? view, args
      @current_view = view = ok_view view, args
      args = default_render_args view, args
      with_inclusion_mode view do
        Card::ViewCache.fetch(self, view, args) do
          method = view_method view, args
          method.arity == 0 ? method.call : method.call(args)
        end
      end
    rescue => e
      rescue_view e, view
    end

    def view_method view, args
      method "_view_#{view}"
    rescue
      args[:unsupported_view] = view
      method '_view_unsupported_view'
    end

    def hidden_view? view, args
      args.delete(:optional) && !show_view?(view, args)
    end

    def show_view? view, args
      default = args.delete(:default_visibility) || :show # FIXME: - ugly
      api_option = args["optional_#{view}".to_sym]
      case
      # permanent visibility specified in code
      when api_option == :always then true
      when api_option == :never  then false
      else
        # wagneer can override code settings
        contextual_setting = nest_arg_visibility(view, args) || api_option
        case contextual_setting
        when :show               then true
        when :hide               then false
        else default == :show
        end
      end
    end

    def nest_arg_visibility view, args
      [:show, :hide].each do |setting|
        return setting if parse_view_visibility(args[setting]).member?(view)
      end
      false
    end

    def parse_view_visibility val
      case val
      when NilClass then []
      when Array    then val
      when String   then val.split(/[\s,]+/)
      else raise Card::Error, "bad show/hide argument: #{val}"
      end.map { |view| canonicalize_view view }
    end

    def default_render_args view, a=nil
      args =
        case a
        when nil   then {}
        when Hash  then a.clone
        when Array then a[0].merge a[1]
        else       raise Card::Error, "bad render args: #{a}"
        end

      default_method = "default_#{view}_args"
      if respond_to? default_method
        send default_method, args
      end
      args
    end

    def rescue_view e, view
      if Rails.env =~ /^cucumber|test$/
        raise e
      else
        Rails.logger.info "\nError rendering #{error_cardname} / #{view}: "\
                          "#{e.class} : #{e.message}"
        Card::Error.current = e
        card.notable_exception_raised
        if (debug = Card[:debugger]) && debug.content == 'on'
          raise e
        else
          rendering_error e, view
        end
      end
    end

    def error_cardname
      card && card.name.present? ? card.name : 'unknown card'
    end

    def rendering_error _exception, view
      "Error rendering: #{error_cardname} (#{view} view)"
    end

    #
    # ------------- Sub Format and Inclusion Processing ------------
    #

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

    def process_content override_content=nil, opts={}
      process_content_object(override_content, opts).to_s
    end

    def process_content_object override_content=nil, opts={}
      content = override_content || render_raw || ''
      content_object = get_content_object content, opts
      if card.references_expired
        card.update_references content_object
      end
      content_object.process_each_chunk do |chunk_opts|
        prepare_nest chunk_opts.merge(opts) { yield }
      end
    end

    def get_content_object content, opts
      if content.is_a? Content
        content
      else
        Content.new content, self, opts.delete(:content_opts)
      end
    end

    def ok_view view, args={}
      return view if args.delete :skip_permissions
      approved_view = approved_view view, args
      args[:denied_view] = view if approved_view != view
      if focal? && (error_code = @@error_code[approved_view])
        root.error_status = error_code
      end
      approved_view
    end

    def approved_view view, args={}
      case
      when @depth >= Card.config.max_depth
        # prevent recursion. @depth tracks subformats
        :too_deep
      when @@perms[view] == :none
        # permission skipping specified in view definition
        view
      when args.delete(:skip_permissions)
        # permission skipping specified in args
        view
      when !card.known? && !tagged(view, :unknown_ok)
        # handle unknown cards (where view not exempt)
        view_for_unknown view, args
      else
        # run explicit permission checks
        permitted_view view, args
      end
    end

    def tagged view, tag
      self.class.tagged view, tag
    end

    def permitted_view view, args
      perms_required = @@perms[view] || :read
      args[:denied_task] =
        if Proc === perms_required
          :read if !(perms_required.call self)  # read isn't quite right
        else
          [perms_required].flatten.find { |task| !ok? task }
        end

      if args[:denied_task]
        @@denial[view] || :denial
      else
        view
      end
    end

    def ok? task
      task = :create if task == :update && card.new_card?
      @ok ||= {}
      @ok[task] = card.ok? task if @ok[task].nil?
      @ok[task]
    end

    def view_for_unknown _view, _args
      # note: overridden in HTML
      focal? ? :not_found : :missing
    end

    def canonicalize_view view
      return if view.blank?
      view_key = view.to_viewname.key.to_sym
      DEPRECATED_VIEWS[view_key] || view_key
    end

    def with_inclusion_mode mode
      if (switch_mode = INCLUSION_MODES[mode]) && @mode != switch_mode
        old_mode, @mode = @mode, switch_mode
        @inclusion_defaults = nil
      end
      result = yield
      if old_mode
        @inclusion_defaults = nil
        @mode = old_mode
      end
      result
    end

    def prepare_nest opts
      @char_count ||= 0
      opts ||= {}

      case
      when opts.has_key?(:comment)
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

    def expand_main opts
      opts.merge! root.main_opts if root.main_opts
      legacy_main_opts_tweaks! opts

      with_inclusion_mode :normal do
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

    def wrap_main content
      content  # no wrapping in base format
    end

    def nest nested_card, opts={}
      # ActiveSupport::Notifications.instrument('card', message:
      # "nest: #{nested_card.name}, #{opts}") do
      opts.delete_if { |_k, v| v.nil? }
      opts.reverse_merge! inclusion_defaults(nested_card)

      sub = nil
      if opts[:inc_name] =~ /^_(self)?$/
        sub = self
      else
        sub = subformat nested_card
        sub.inclusion_opts = opts[:items] ? opts[:items].clone : {}
      end

      view = canonicalize_view opts.delete :view
      opts[:home_view] = [:closed, :edit].member?(view) ? :open : view
      # FIXME: special views should be represented in view definitions

      view =
        case @mode
        when :edit     then view_in_edit_mode(view, nested_card)
        when :template then :template_rule
        when :closed   then view_in_closed_mode(view, nested_card)
        else                view
        end

      sub.optional_render view, opts
      # end
    end

    def view_in_edit_mode homeview, nested_card
      not_in_form =
        @@perms[homeview] == :none || # view configured not to keep in form
        nested_card.structure || #      not yet nesting structures
        nested_card.key.blank? #        eg {{_self|type}} on new cards

      not_in_form ? :blank : :edit_in_form
    end

    def view_in_closed_mode homeview, nested_card
      approved_view = @@closed[homeview]
      case
      when approved_view == true  then homeview
      when @@error_code[homeview] then homeview
      when approved_view          then approved_view
      when !nested_card.known?    then :closed_missing
      else                             :closed_content
      end
    end

    def get_inclusion_content cardname
      content = params[cardname.to_s.tr('+', '_')]

      # CLEANME This is a hack so plus cards re-populate on failed signups
      p = params['subcards']
      if p && (card_params = p[cardname.to_s])
        content = card_params['content']
      end
      content if content.present? # returns nil for empty string
    end

    def fetch_nested_card options
      args = { name: options[:inc_name], type: options[:type], supercard: card }
      args.delete(:supercard) if options[:inc_name].strip.blank?
      # special case.  gets absolutized incorrectly. fix in smartname?
      if options[:inc_name] =~ /^_main\+/
        # FIXME: this is a rather hacky (and untested) way to get @superleft
        # to work on new cards named _main+whatever
        args[:name] = args[:name].gsub /^_main\+/, '+'
        args[:supercard] = root.card
      end
      if (content = get_inclusion_content options[:inc_name])
        args[:content] = content
      end
      Card.fetch options[:inc_name], new: args
    end

    def default_item_view
      :name
    end

    #
    # ------------ LINKS ---------------
    #

    def add_class options, klass
      options[:class] = [options[:class], klass].flatten.compact * ' '
    end

    def unique_id
      "#{card.key}-#{Time.now.to_i}-#{rand(3)}"
    end

    def format_date date, include_time=true
      # using DateTime because Time doesn't support %e on some platforms
      if include_time
        DateTime.new(
          date.year, date.mon, date.day, date.hour, date.min, date.sec
        ).strftime('%B %e, %Y %H:%M:%S')
      else
        DateTime.new(date.year, date.mon, date.day).strftime('%B %e, %Y')
      end
    end

    def add_name_context name=nil
      name ||= card.name
      @context_names += name.to_name.part_names
      @context_names.uniq!
    end
  end
end
