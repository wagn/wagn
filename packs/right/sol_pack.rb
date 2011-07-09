class Wagn::Renderer::RichHtml
  # from app/view/card/_declare.rhtml
  define_view(:declare_form, :right=>'*sol') do |args|
    @form = form_for_multi
    @state=:edit
    %{#{div( :id=>slot.id('declar-area'),
             :class=>"declaror declar-area #{card.hard_template ? :templated : ''}" ) do
      form_for_card :url=>"card/update/#{card.name.to_url_key}",
                    :slot=>slot, :html=>{ :class=>'form editor',
                    :onsubmit=>slot.save_function,
                    :id=>(slot.context + '-form') } do |form|
        concat %{<div>#{
          slot.form = form
          trait_submenu(:declare, (card.attribute||=:declare))}#{
          #(args[:view] != 'setting' && inst = card.setting_card('declare help') ?
             #%{<div class="instruction">#{slot.subslot(inst).render :naked }</div>} : '') +
          hidden_field_tag( :multi_edit, true)}#{
          hidden_field_tag( :attribute, card.attribute )}#{
          hidden_field_tag( :ctxsig, card.signature)}#{
          expand_inclusions( trait_form(card.attribute) )
          }</div>#{
          slot.captcha_tags
          }<div class="declare-button-area">#{
          hidden_field_tag(:attribute, card.attribute )}#{
          button_to_function "Declare", "this.form.onsubmit()", :class=>'save-card-button' }#{
          slot.button_to_action 'Cancel', 'view', { :before=>slot.cancel_function }
          }</div>
        }
      end
    end
  }}
  end

=begin
  define_view(:multi_edit) do |args|
    @state=:edit
    args[:add_javascript]=true #necessary?
    @form = form_for_multi
    hidden_field_tag(:multi_edit, true) + _render_naked(args)
  end
=end


  # from app/view/card/declare.rhtml
  #define_view(:declare, :right=>'*sol') do
  define_view(:declare) do |args|
    tcard = @card.trait_card('*sol')
    raise "No card" unless tcard

    wrap( args ) do
      %{#{slot.header
      }<style>.SELF-#{tcard.key.css_name
      } .declare-area .title-#{
        tcard.name.css_name
      } { display: none; }</style>} +

      div( :id=>id('card-body'), :class=>'card-body') do
        Rails.logger.debug "render declare sub #{tcard&&tcard.name}"
        self.subrenderer(tcard).render(:declare_form)
      end + notice
    end
  end

  # Traits can have submenus: This is the links for differet form selections
  def trait_submenu(menu_name, on)
    menu_name = menu_name.to_s
    div(:class=>'submenu') do
      trait_forms(menu_name) do |key, ok, args|
        if ok
          link_to_remote( key, { :url=>url_for("card/#{menu_name}",args,key),
              :update => id , :menu => key}, :class=>(key==on.to_s ? 'on' : '') )
        end
      end
    end
  end

  def trait_forms(menu_name)
    if formcard = card.setting_card(menu_name.to_star) and
       (formtype = formcard.typecode) == 'Pointer'
      Rails.logger.debug "trait_forms(#{menu_name}) #{card&&card.name}, #{formcard&&formcard.name}"
      # is this names or cards? new api?
      if block_given?
        formcard.item_names.map { |item| yield(item.tag_name, true, []) }
      else
        formcard.item_names.map {|i| i.gsub!(/^\[\[|\]\]$/, '');}
      end
    else
      return if block_given?
      return %{#{formcard ? "Setting not a Pointer [#{formtype}]" : "Missing setting"
                } for #{card&&card.name}, #{menu_name.to_star}}
    end
  end

  def trait_form(action)
    forms = trait_forms(action=action.to_s)
    return forms if String === forms
    Rails.logger.info "trait_form(#{action.inspect}) #{forms.inspect}"
    if form = forms.find { |k|
      Rails.logger.info "trait_search(#{action.inspect}) #{card.attribute.inspect}, #{k.tag_name.inspect} #{forms.inspect}"
      k.tag_name == action } and form = Card.fetch(form)
      form.content
    else
      "No form card #{@state} #{card&&card.name}"
    end
  end
end
