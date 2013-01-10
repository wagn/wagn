module Wagn

  LAYOUTS = { 'default' => {:status => "{{:status}}",:result => "{{_main}}"},
              'none' => "{{_main}}"
            }

 class Renderer::JsonRenderer < Renderer

  cattr_accessor :set_actions
  attr_accessor  :options_need_save, :js_queue_initialized,
    :position, :start_time, :skip_autosave

  # This creates a separate class hash in the subclass
  class << self
    def actions() @@set_actions||={} end
  end

  def set_action(key)
    Renderer::JsonRenderer.actions[key] or super
  end

  def initialize(card, opts=nil)
    super
    @context = "main_1" unless @context =~ /\_/
    @position = @context.split('_').last
    @state = :view
    @renders = {}
    @js_queue_initialized = {}

    if card and card.collection? and item_param=params[:item]
      @item_view = item_param if !item_param.blank?
    end
  end

  def build_link href, text, known_card=nil
    #Rails.logger.warn "bl #{href.inspect}, #{text.inspect}, #{known_card.inspect}"
    klass = case href.to_s
      when /^https?:/; 'external-link'
      when /^mailto:/; 'email-link'
      when /^\//
        href = full_uri href.to_s
        'internal-link'
      else
        known_card = !!Card.fetch(href, :skip_modules=>true) if known_card.nil?
        smartname = href.to_name
        text = smartname.to_show(card.name) unless text
        #href+= "?type=#{type.to_url_key}" if type && card && card.new_card?  WANT THIS; NEED TEST
        href = full_uri Wagn::Conf[:root_path] + '/' +
          (known_card ? smartname.to_url_key : CGI.escape(smartname.escape))

        return %{{"cardlink":{"class":"#{
                    known_card ? 'known-card' : 'wanted-card'
                  }", "url":"#{href}","text":"#{text}"}}}
      end
    { :link => { :class => "#{klass}", :url => "#{href}",:text => "#{text}"}} # return a Hash, not a string for json
  end

  def wrap(view=nil, args = {})

    attributes = card.nil? ? {} : {
        :name     => card.cardname.tag_name.to_s,
        :key      => card.key,
        :cardId   => card.id,
        :type     => card.type_name,
      }
    [:style, :home_view, :item, :base].each { |key| a = args[key] and attributes[key] = a }

    cont = yield  # (Enumerable===(c=yield) ? c.to_a : c)
    #Rails.logger.info "wrap json #{cont.class}, I#{cont.inspect}"
    {card: { attr: attributes, content: cont }}
  end

  def get_layout_content(args)
    Account.as_bot do
      case
        when (params[:layout] || args[:layout]) ;  layout_from_name
        when card                               ;  layout_from_card
        else                                    ;  LAYOUTS['default']
      end
    end
  end

  def layout_from_name
    lname = (params[:layout] || args[:layout]).to_s
    lcard = Card.fetch(lname, :skip_virtual=>true)
    case
      when lcard && lcard.ok?(:read)         ; lcard.content
      when hardcoded_layout = LAYOUTS[lname] ; hardcoded_layout
      else  ; %{{"error":"Unknown layout: #{lname}.  Built-in Layouts: #{LAYOUTS.keys.join(', ')}}}

    end
  end

  def layout_from_card
    return unless rule_card = (card.rule_card(:layout) or Card.default_rule_card(:layout))
    rule_card.include_set_modules
    return unless rule_card.type_id == Card::PointerID           and
      layout_name=rule_card.item_names.first                and
      !layout_name.nil?                                        and
      lo_card = Card.fetch(layout_name, :skip_virtual => true) and
      lo_card.ok?(:read)
    lo_card.content
  end

 end
end
