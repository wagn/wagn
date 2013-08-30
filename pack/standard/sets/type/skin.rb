# -*- encoding : utf-8 -*-

include Card::Set::Type::Pointer

view :core do |args|
  card.item_names.join ', '
end

format :html do

  view :core do |args|
    %{<div class="pointer-list">#{ pointer_items args[:item] }</div>}
  end

  view :closed_content do |args|
    itemview = (args[:item] || inclusion_defaults[:view])=='name' ? 'name' : 'link'
    %{<div class="pointer-list">#{ pointer_items itemview }</div>}
  end

  view :editor do |args|
    part_view = (c = card.rule(:input)) ? c.gsub(/[\[\]]/,'') : :list
    form.hidden_field( :content, :class=>'card-content') +
    raw(_render(part_view))
  end

  view :list do |args| #this is a permission view.  should it go with them?
    args ||= {}
    items = args[:item_list] || card.item_names(:context=>:raw)
    items = [''] if items.empty?
    options_card_name = (oc = card.options_card) ? oc.cardname.url_key : ':all'

    extra_css_class = args[:extra_css_class] || 'pointer-list-ul'

    %{<ul class="pointer-list-editor #{extra_css_class}" options-card="#{options_card_name}"> } +
    items.map do |item|
      %{<li class="pointer-li"> } +
        text_field_tag( 'pointer_item', item, :class=>'pointer-item-text', :id=>'asdfsd' ) +
        link_to( '', '#', :class=>'pointer-item-delete ui-icon ui-icon-circle-close' ) +
      '</li>'
    end.join("\n") +
    %{</ul><div class="add-another-div">#{link_to 'Add another','#', :class=>'pointer-item-add'}</div>}

  end

  view :checkbox do |args|
    %{<div class="pointer-checkbox-list">} +
    card.options.map do |option|
      checked = card.item_names.include?(option.name)
      id = "pointer-checkbox-#{option.cardname.key}"
      %{<div class="pointer-checkbox"> } +
        check_box_tag( "pointer_checkbox", option.name, checked, :id=>id, :class=>'pointer-checkbox-button' ) +
        %{<label for="#{id}">#{option.name}</label> } +
        ((description = card.option_text(option.name)) ?
          %{<div class="checkbox-option-description">#{ description }</div>} : '' ) +
      "</div>"
    end.join("\n") +
    '</div>'
  end

  view :multiselect do |args|
    options = options_from_collection_for_select(card.options,:name,:name,card.item_names)
    select_tag("pointer_multiselect", options, :multiple=>true, :class=>'pointer-multiselect')
  end

  view :radio do |args|
    input_name = "pointer_radio_button-#{card.key}"
    options = card.options.map do |option|
      checked = (option.name==card.item_names.first)
      id = "pointer-radio-#{option.cardname.key}"
      description = card.option_text(option.name)
      %{ <div class="pointer-radio"> } +
        radio_button_tag( input_name, option.name, checked, :id=>id, :class=>'pointer-radio-button' ) +
        %{<label for="#{id}">#{ option.name }</label> } +
        (description ? %{<div class="radio-option-description">#{ description }</div>} : '') +
      '</div>'
    end.join("\n")

    %{ <div class="pointer-radio-list">#{options}</div> }
  end

  view :select do |args|
    options = [["-- Select --",""]] + card.options.map{|x| [x.name,x.name]}
    select_tag("pointer_select", options_for_select(options, card.item_names.first), :class=>'pointer-select')
  end
  
end


format :css do
  view :content do |args|
    %(#{major_comment "STYLE GROUP: \"#{card.name}\"", '='}#{ _render_core })
  end
  
  view :core do |args|
    card.item_cards.map do |item|
      process_inclusion item
    end.join "\n\n"
  end
end
