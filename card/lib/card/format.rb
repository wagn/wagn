# -*- encoding : utf-8 -*-

class Card
  # The {Format} class is a key strut in the MoFoS
  # _(Model-Format-Set)_ architecture.
  #
  # The primary means of transacting with the card Model (cards across time)
  # is the _event_.  The primary means for displaying card content (cards across
  # space) is the _view_. __Format objects manage card views__.
  #
  # Here is a very simple view that just displays the card's id:
  #
  # ```` view(:simple_content) { card.raw_content } ````
  #
  # But suppose you would like this view to appear differently in different
  # output formats.  You might need certain characters escaped in some formats
  # (csv, html, etc) but not others.  You might like to make use of the
  # aesthetic or structural benefits certain formats allow.
  #
  # To this end we have format classes. {Format::HtmlFormat},
  # {Format::JsonFormat}, {Format::XmlFormat}, etc, each are descendants of
  # {Card::Format}.
  #
  # For information on how Formats intersect with Sets, see {Card::Set::Format}
  #
  class Format
    include Card::Env::Location
    include Nest
    include Permission
    include Render
    include Names
    include Content
    include Error

    extend Registration

    # FIXME: should be set in views

    cattr_accessor :ajax_call, :registered
    self.registered = []
    [:perms, :denial, :closed, :error_code,
     :view_tags, :aliases].each do |accessor_name|
      cattr_accessor accessor_name
      send "#{accessor_name}=", {}
    end

    attr_reader :card, :root, :parent, :main_opts, :mode
    attr_accessor :form, :error_status

    def initialize card, opts={}
      @card = card
      require_card_to_initialize!

      opts.each { |key, value| instance_variable_set "@#{key}", value }

      @mode ||= :normal
      @root ||= self
      @depth ||= 0

      @context_names = initial_context_names
      include_set_format_modules
      self
    end

    def require_card_to_initialize!
      return if @card
      msg = I18n.t :exception_init_without_card, scope: "lib.card.format"
      raise Card::Error, msg
    end

    def include_set_format_modules
      self.class.format_ancestry.reverse_each do |klass|
        card.set_format_modules(klass).each do |m|
          singleton_class.send :include, m
        end
      end
    end

    def page view, slot_opts
      @card.run_callbacks :show_page do
        show view, slot_opts
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
      @depth.zero?
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
        api_render Regexp.last_match, opts
      else
        pass_method_to_template_object(method, opts, proc) { yield }
      end
    end

    def respond_to_missing? method_name, _include_private=false
      (method_name =~ /(_)?(optional_)?render(_(\w+))?/) ||
        template.respond_to?(method_name)
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
