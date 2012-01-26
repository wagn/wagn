module Wagn
 class Renderer::Xml < Renderer

  LAYOUTS = { 'default' => %{
<carddoc>
{{_main}}
</carddoc>
} }

  cattr_accessor :set_actions
  attr_accessor  :options_need_save, :js_queue_initialized,
    :position, :start_time, :skip_autosave

  # This creates a separate class hash in the subclass
  class << self
    def actions() @@set_actions||={} end
  end

  def set_action(key)
    Renderer::Xml.actions[key] or super
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

  def build_link(href, text)
    klass = case href
      when /^https?:/; 'external-link'
      when /^mailto:/; 'email-link'
      when /^\//
        href = full_uri(href)
        'internal-link'
      else
        known_card = !!Card.fetch(href)
        cardname = href.to_cardname
        text = cardname.to_show(card.name) unless text
        href = href.to_cardname
        href = Wagn::Conf[:root_path] + '/' + (known_card ? href.to_url_key : CGI.escape(href.escape))
        #href+= "?type=#{type.to_url_key}" if type && card && card.new_card?  WANT THIS; NEED TEST
        href = full_uri(href.to_s)

        return %{<cardlink class="#{
                    known_card ? 'known-card' : 'wanted-card'
                  }" card="#{href}">#{text}</cardlink>}
      end
    %{<link class="#{klass}" href="#{href}">#{text}</link>}
  end   
          
  def wrap(view=nil, args = {})
    css_class = case args[:action].to_s
      when 'content'  ;  'transcluded'
      when 'exception';  'exception'
      when 'closed'   ;  'card-slot line'
      else            ;  'card-slot paragraph'
    end 
    css_class << " " + card.css_names if card
    css_class << " view-#{view}" if view
    
    attributes = {
      :name => card.cardname.tag_name,
      :cardId   => (card && card.id),
      :type     => card.typecode,
      :class    => css_class,
    }
    [:style, :home_view, :item, :base].each { |key| attributes[key] = args[key] }
    
    content_tag(:card, attributes ) { yield }
  end

  def get_layout_content(args)
    Card.as(Card::WagbotID) do
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
      else  ; "<h1>Unknown layout: #{lname}</h1>Built-in Layouts: #{LAYOUTS.keys.join(', ')}"
    end
  end

  def layout_from_card
    return unless setting_card = (card.setting_card('layout') or Card.default_setting_card('layout'))
    return unless setting_card.typecode == 'Pointer'           and
      layout_name=setting_card.item_names.first                and
      !layout_name.nil?                                        and
      lo_card = Card.fetch(layout_name, :skip_virtual => true) and
      lo_card.ok?(:read)
    lo_card.content
  end


 end
end
