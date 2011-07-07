module Wagn::Renderer::RichHtml
  # from app/view/card/_declare.rhtml
  define_view(:declare_form, :type=>'Sol') do
    trait_submenu(:declare, params[:attribute]||:declare) +
    (params[:view] != 'setting' && inst = card.setting_card('declare help') ?
      %{<div class="instruction">#{slot.subslot(inst).render :naked }</div>} : '') +

    div( :id=>slot.id('declare-area'), :class=>"declaror declare-area #{card.hard_template ? :templated : ''}" ) do

      wagn_form_for :card, card, :url=>"card/declare", :slot=>slot,
         :html=>{ :class=>'form declaror',:onsubmit=>slot.save_function,
         :id=>(slot.context + '-form') } do |form|
        %{<div>#{slot.form = form
                 # from slot.render #when :declare;
                   @state= symbolize_param(:attribute) || :declare
                   args[:add_javascript]=true
                   hidden_field_tag( :multi_edit, true)}#{
                   hidden_field_tag( :attribute, @state )}#{
                   hidden_field_tag( :ctxsig, card.signature)}#{
                   expand_inclusions( trait_form(@state) )
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


  # from app/view/card/declare.rhtml
  define_view(:declare, :type=>'Sol') do
    raise "No card" unless @card
    hard_template = @card.hard_template

    wrap( 'declare' ) do
      %{#{header
      }<style>#{
        ".SELF-#{@card.key.css_name
      } .declare-area .title-#{
        @card.name.css_name
      } { display: none; }" }</style>} +

      div( :id=>id('card-body'), :class=>'card-body') do
         _render_declare_form
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
    end.compact.join
  end

  def trait_forms(menu_name)
    return unless formcard = card.setting_card(menu_name.to_star) and
             formcard.typecode == 'Pointer'
    # is this names or cards? new api?
    block_given? ?
      formcard.item_names.map { |item| yield(item.tag_name, true, []) } :
      formcard.item_names
  end

  # and this
  def trait_form(action)
    raise "No tag" unless action_traits[action]
    Card.fetch( trait_forms(action.to_s).
                find { |k| k.tag_name == @state.to_s } ).content
  end
end
