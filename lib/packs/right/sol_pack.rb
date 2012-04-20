class Wagn::Renderer::Html
  # from app/view/card/_declare.rhtml
  define_view(:declare_form, :right=>'sol') do |args|
    @form = form_for_multi
    @state=:edit
    %{<div id="declar-area" class="declaror declar-area #{card.hard_template ? :templated : ''}"> #{
      card_form :update, 'card-form card-declare-form' do |form|
        %{<div>#{
          slot.form = form
          trait_submenu(:declare, (card.attribute||=:declare))}#{
          #(args[:view] != 'setting' && inst = card.rule_card(:declare_help) ?
             #%{<div class="instruction">#{slot.subslot(inst).render :naked }</div>} : '') +
          hidden_field_tag( :multi_edit, true)}#{
          hidden_field_tag( :attribute, card.attribute )}#{
          hidden_field_tag( :ctxsig, card.signature)}#{
          trait_form(card.attribute)
          }</div>
          <div class="declare-button-area">#{
          hidden_field_tag(:attribute, card.attribute )}#{
          button_tag "Declare", :class=>'edit-submit-button'}#{
          button_tag 'Cancel', :class=>'edit-cancel-button slotter', :href=>path(:view)
          }</div>
        }
      end}
    </div>}
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
  #define_view(:declare, :trait=>:sol) do
  define_view(:declare) do |args|
    tcard = @card.trait_card(:sol)
    raise "No card" unless tcard

    Rails.logger.info "declare (#{@card.name}) #{tcard.inspect}"
    wrap( args ) do
      %{#{#slot.header  I don't understand why this doesn't work here?
      }<style>.SELF-#{tcard.cardname.css_name
      } .declare-area .title-#{
        tcard.cardname.css_name
      } { display: none; }</style>} +

      %{<div id="card-body" class="card-body">#{
        Rails.logger.debug "render declare sub #{tcard&&tcard.name}"
        self.subrenderer(tcard).render(:declare_form)
      }#{ notice }
      </div> }
    end
  end

  # Traits can have submenus: This is the links for differet form selections
  def trait_submenu(menu_name, on)
    menu_name = menu_name.to_s
    current = params[:attribute] || menu_name
    %{<div class="submenu"> #{
      trait_forms(menu_name) do |key, ok, args|
        if ok
            text = key.gsub('*','').gsub('subtab','').strip
            link_to text, path(:declare, :attrib=>key), :remote=>true,
              :class=>"slotter #{key==current ? 'current-subtab' : ''}"
        end
      end.compact * "\n"}
    </div>}
  end

  def trait_forms(menu_name)
    if formcard = card.rule_card(menu_name) and
       (formtype = formcard.typecode) == 'Pointer'
      #warn (Rails.logger.debug "trait_forms(#{menu_name}) #{card&&card.name}, #{formcard&&formcard.name}")
      # is this names or cards? new api?
      if block_given?
        formcard.item_names.map { |item| yield(item.to_cardname.tag_name, true, []) }
      else formcard.item_names end
    else
      #return if block_given?
      raise %{#{formcard ? "Setting not a Pointer [#{formtype}]" : "Missing setting"
                } for #{card&&card.name}, #{menu_name}}
    end
  end

  def trait_form(action)
    forms = trait_forms(action=action.to_s)
    return forms if String === forms
    #warn (Rails.logger.info "trait_form(#{action.inspect}) #{forms.inspect}")
    if form = forms.find { |k|
      #warn (Rails.logger.info "trait_search(#{action.inspect}) #{card.attribute.inspect}, #{k.to_cardname.tag_name.inspect} #{forms.inspect}")
      k.to_cardname.tag_name == action } and form = Card.fetch(form)
      subrenderer(form).render_edit_in_form
    else
      "No form card #{@state} #{card&&card.name}"
    end
  end
end
