module Wagn::Model::Traits
  def self.included(base)
    super
    Rails.logger.debug "add card methods for traits #{base} #{self}"
    # class hash to register the traits, and the registration function
    base.class_eval {
      cattr_accessor :trait_options 
      cattr_accessor :action_traits
    }
    base.extend(CardMethods)
  end

  module CardMethods
    def register_trait(trait_name, *options)
      options = options[0] if options.length == 1
      trait_options[trait_name] = options
      @menu_options=nil
    end
  end

  define_view(:declare, :type=>'Sol') do
    get_slot.trait_submenu('*sol', :declare, params[:attribute]||:declare) +
    (params[:view] != 'setting' && inst = card.setting_card('declare help') ?
      %{<div class="instruction">#{slot.subslot(inst).render :naked }</div>} : '') +

    div( :id=>slot.id('declare-area'), :class=>"declaror declare-area #{card.hard_template ? :templated : ''}" ) do

      wagn_form_for :card, card, :url=>"card/declare", :slot=>slot,
         :html=>{ :class=>'form declaror',:onsubmit=>slot.save_function,
         :id=>(slot.context + '-form') } do |form|
        %{<div>#{slot.form = form
                 slot.render( :declare ) #  ???
          }</div>#{
          slot.half_captcha
          }<div class="declare-button-area">#{
          hidden_field_tag(:attribute,params[:attribute]||:declare )}#{
          button_to_function "Declare", "this.form.onsubmit()", :class=>'save-card-button' }#{
          slot.button_to_action 'Cancel', 'view', { :before=>slot.cancel_function }
          }</div>}
      end
    end
  end

  # more from declare
  define_view(:declare) do
    raise "No card" unless @card
    hard_template = @card.hard_template

   get_slot.wrap( 'declare' ) do |slot|
    %{#{slot.header
    }<style>#{ ".SELF-#{@card.key.css_name} .declare-area .title-#{@card.name.css_name} { display: none; }" }</style>}+

    div( :id=>slot.id('card-body'), :class=>'card-body') do
      slot.render_partial 'card/declare'
    end +
    slot.notice
  end

  # ??? move this to ? maybe views (a pack?)
  # Traits can have submenus
  def trait_submenu(trait_name, menu_name, on)
    menu_name = menu_name.to_s
    div(:class=>'submenu') do
      trait_forms(trait_name, menu_name) do |keycard, tcard, ok, args|
        key = keycard.name
        if ok
          link_to_remote( key, { :url=>url_for("card/#{menu_name}",args,key),
              :update => id , :menu => key}, :class=>(key==on.to_s ? 'on' : '') )
        end
      end
    end.compact.join
  end

  # and this
  def trait_forms(trait_name, menu_name)
    return unless trait_card = trait_card(trait_name.to_s) and
             formcard = trait_card.setting_card(menu_name.to_star) and
             formcard.is_a?(Card::Pointer)
    formcard.pointees.map do |item|
      if c = Card.fetch(item, :skip_virtual=>true) and
         trait_name = (c.trait_name || c)
        block_given? ? yield(trait_name, c, true, []) : trait_name
      end
    end
  end

  # and this
  def trait_form(action)
    # FIXME: this seems wrong, what is it for, where should it go?
    #'*sol' if action == :declare
    trait_tag = action_traits[action]
    raise "No tag" unless trait_tag
    which_form = nil #@state.to_s
    trait_forms(trait_tag, action.to_s) do |keycard, tcard, ok, args|
      which_form = tcard if keycard.name == @state.to_s or not which_form
    end
    which_form.content
  end

  # was in Card::Base
  # A card has a 'trait' if card+trait_name exists
  def trait_card(trait_name) 
r=
    trait_cards[trait_name.to_sym] ||= fetch(name+JOINT+trait_name)
Rails.logger.info("trait_card #{self}, #{trait_name} = #{r}"); r
  end
  def trait_cards() @trait_cards ||= []; end
  def has_trait?(trait_name) true if trait_card(trait_name); end
     
  def traits
    trait_options().keys.map do |trait_name|
      if trait_card(trait_name)
        Rails.logger.info("tag_trait: #{name} + #{trait_name} #{trait_card.name}")
        block_given? ? yield(trait_name, trait_card(trait_name)) : trait_name
      end
    end.compact
  end  
        
  # adds options to right-menu for traits
  def menu_options(options=[])
    @menu_options ||= traits() do |trait_name, trait_card|
      trait_opts = trait_options()[trait_name]
      trait_list = []
      Rails.logger.info("menu_options N: #{trait_name} #{trait_opts}")
      if Hash===trait_opts
        trait_opts.each_pair do |where, what|
          trait_list.push(*what)
          if where == :right
            options.push(*what)
          elsif where == :left
            options.unshift(*what)
          elsif Array === where
            action, location = where
            idx = 0
            if Symbol===location
              idx = options.index(location)
            elsif Fixnum===location
              idx = location
              idx = options.length+idx+1 if idx<0
            else raise "Location? #{location.class} #{location.inspect}"
            end
            if action == :left_of or action == :before
              idx = if idx then idx-1 else -1 end
            elsif action == :right_of or action == :after
              idx = options.length unless idx
            else raise "Action? #{action.inspect}"
            end
            idx = options.length if idx > options.length
            if idx < 0
              options.unshift(*what)
            else
              options[idx,0] = what
            end
          end
        end
      else
        if Array===trait_opts and trait_opts.length > 0 or trait_opts
          trait_list.push(*trait_opts)
          options.push(*trait_opts)
        end
      end
    end
    action_traits[trait_name] = trait_list
    options
  end
end
