# -*- encoding : utf-8 -*-

class Card
  class Format
    include Card::Location
    include Nest
    include Permission
    include Render

    DEPRECATED_VIEWS = { view: :open, card: :open, line: :closed,
                         bare: :core, naked: :core }.freeze

    # FIXME: should be set in views

    cattr_accessor :ajax_call, :registered
    [:perms, :denial, :closed, :error_code,
     :view_tags, :aliases].each do |accessor_name|
      cattr_accessor accessor_name
      send "#{accessor_name}=", {}
    end

    attr_reader :card, :root, :parent, :main_opts
    attr_accessor :form, :error_status, :nest_opts

    class << self
      @@registered = []

      def register format
        @@registered << format.to_s
      end

      def format_class_name format
        format = format.to_s
        format = "" if format == "base"
        format = @@aliases[format] if @@aliases[format]
        "#{format.camelize}Format"
      end

      def format_sym format
        return format if format.is_a? Symbol
        match = format.to_s.match(/::(?<format>[^:]+)Format/)
        match ? match[:format] : :base
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
        ancestry += superclass.format_ancestry unless self == Card::Format
        ancestry
      end

      def max_depth
        Card.config.max_depth
      end
    end

    # ~~~~~ INSTANCE METHODS

    def initialize card, opts={}
      unless (@card = card)
        raise Card::Error, # 'format initialized without card'
              I18n.t(:exception_init_without_card,
                     scope: "lib.card.format")
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
        part_keys = @card.cardname.part_names.map(&:key)
        @context_names.reject { |n| !part_keys.include? n.key }
      when params[:slot]
        context_name_list = params[:slot][:name_context].to_s
        context_name_list.split(",").map(&:to_name)
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
        title.to_name.to_absolute_name(card.cardname).to_show(*@context_names)
      else
        @showname ||= card.cardname.to_show(*@context_names)
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
      @depth.zero?
    end

    def focal? # meaning the current card is the requested card
      if Env.ajax?
        @depth.zero?
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
        view = Regexp.last_match(3) ? Regexp.last_match(4) : opts.shift
        args = opts[0] ? opts.shift.clone : {}
        if Regexp.last_match(2)
          args[:optional] = true
          args[:default_visibility] = opts.shift
        end
        args[:skip_permissions] = true if Regexp.last_match(1)
        render view, args
      else
        proc = proc { |*a| raw yield(*a) } if proc
        response = root.template.send method, *opts, &proc
        response.is_a?(String) ? root.template.raw(response) : response
      end
    end

    #
    # ------------- Sub Format and Inclusion Processing ------------
    #

    def process_content override_content=nil, opts={}
      process_content_object(override_content, opts).to_s
    end

    def process_content_object override_content=nil, opts={}
      content = override_content || render_raw || ""
      content_object = get_content_object content, opts
      content_object.process_each_chunk do |chunk_opts|
        # Feels scary to just remove it but I can't make any sense of the
        # "yield" and all tests pass without it
        prepare_nest chunk_opts.merge(opts)
      end
    end

    def get_content_object content, opts
      if content.is_a? Content
        content
      else
        Content.new content, self, opts.delete(:content_opts)
      end
    end

    def tagged view, tag
      self.class.tagged view, tag
    end

    #
    # ------------ LINKS ---------------
    #

    def format_date date, include_time=true
      # using DateTime because Time doesn't support %e on some platforms
      if include_time
        # .strftime('%B %e, %Y %H:%M:%S')
        I18n.localize(DateTime.new(date.year, date.mon, date.day,
                                   date.hour, date.min, date.sec),
                      format: :card_date_seconds)
      else
        # .strftime('%B %e, %Y')
        I18n.localize(DateTime.new(date.year, date.mon, date.day),
                      format: :card_date_only)
      end
    end

    def add_name_context name=nil
      name ||= card.name
      @context_names += name.to_name.part_names
      @context_names.uniq!
    end
  end
end
