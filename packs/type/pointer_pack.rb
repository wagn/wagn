class Wagn::Renderer
  
  define_view(:core, :type=>'pointer') do |args|
    %{<div class="pointer-list"> } +
      pointer_item(self, (@item_view || 'closed')) +
    "</div>" + 
    link_to( 'add/edit', "/card/edit/#{card.id}",#ENGLISH 
      :class=>'standard-slotter add-edit-item',
      :remote=>true
    )
  end

  define_view(:closed_content, :type=>'pointer') do |args|
    div( :class=>"pointer-list" ) do
      pointer_item(self, ('name'==@item_view || params[:item] ? 'name' : 'link'))
    end
  end

  define_view(:editor, :type=>'pointer') do |args|
    part_view = (c = card.setting('input')) ? c.gsub(/[\[\]]/,'') : 'list'
    form.hidden_field( :content, :class=>'card-content') +
    raw(render(part_view))
  end

  define_view(:list, :type=>'pointer') do |args|
    items = args[:items] || card.item_names(:context=>:raw)
    items = [''] if items.empty?

    %{<ul class="pointer-list-ul"> } +
    items.map do |item|
      %{<li class="pointer-li"> } +
        text_field_tag( 'pointer_item', item, :class=>'pointer-item-text', :id=>'asdfsd' ) +
        link_to( 'X', '#', :class=>'pointer-item-delete' ) +
      '</li>'
    end.join("\n") +
    %{<li id="add-pointer-li">#{link_to 'Add another','#', :class=>'pointer-item-add'}</li>} +
    '</ul>'
  end

  define_view(:checkbox, :type=>'pointer') do |args|
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

  define_view(:multiselect, :type=>'pointer') do |args|
    options = options_from_collection_for_select(card.options,:name,:name,card.item_names)
    select_tag("pointer_multiselect", options, :multiple=>true, :class=>'pointer-multiselect')
  end

  define_view(:radio, :type=>'pointer') do |args|
    options = card.options.map do |option|
      checked = (option.name==card.item_names.first)
      id = "pointer-radio-#{option.cardname.key}"
      description = card.option_text(option.name)
      %{ <div class="pointer-radio"> } +
        radio_button_tag( "pointer_radio_button", option.name, checked, :id=>id, :class=>'pointer-radio-button' ) +
        %{<label for="#{id}">#{ option.name }</label> } +
        (description ? %{<div class="radio-option-description">#{ description }</div>} : '') +
      '</div>'
    end.join("\n")
    
    %{ <div class="pointer-radio-list">#{options}</div> }
  end

  define_view(:select, :type=>'pointer') do |args|
    options = [["-- Select --",""]] + card.options.map{|x| [x.name,x.name]} 
    select_tag("pointer_select", options_for_select(options, card.item_names.first), :class=>'pointer-select')
  end
end
