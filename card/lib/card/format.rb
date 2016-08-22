# -*- encoding : utf-8 -*-

class Card
  class Format
    include Card::Env::Location
    include Nest
    include Permission
    include Render
    include Names
    include Content
    include Error
    extend Nest::ClassMethods
    extend Registration

    DEPRECATED_VIEWS = { view: :open, card: :open, line: :closed,
                         bare: :core, naked: :core }.freeze

    # FIXME: should be set in views

    cattr_accessor :ajax_call, :registered
    self.registered = []
    [:perms, :denial, :closed, :error_code,
     :view_tags, :aliases].each do |accessor_name|
      cattr_accessor accessor_name
      send "#{accessor_name}=", {}
    end

    attr_reader :card, :root, :parent, :main_opts
    attr_accessor :form, :error_status, :nest_opts

    def page view, slot_opts
      @card.run_callbacks :show_page do
        show view, slot_opts
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

      @context_names = initialize_context_names
      include_set_format_modules
      self
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
        render_api Regexp.last_match, opts
      else
        pass_method_to_template_object(method, opts, proc) { yield }
      end
    end

    def pass_method_to_template_object method, opts, proc
      proc = proc { |*a| raw yield(*a) } if proc
      response = root.template.send method, *opts, &proc
      response.is_a?(String) ? root.template.raw(response) : response
    end

    def tagged view, tag
      self.class.tagged view, tag
    end
  end
end
