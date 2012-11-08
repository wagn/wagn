class Wagn::Renderer
  define_view :core, :type=>'pointer' do |args|
    card.item_names.join ', '
  end
end


class Wagn::Renderer::Html

  define_view :core, :type=>'pointer' do |args|
    @item_view ||= DEFAULT_ITEM_VIEW
    %{<div class="pointer-list">#{pointer_items}</div>}
    #+ link_to( 'add/edit', path(action), :remote=>true, :class=>'slotter add-edit-item' ) #ENGLISH
  end

  define_view :closed_content, :type=>'pointer' do |args|
    @item_view = 'link' unless @item_view == 'name'
    %{<div class="pointer-list">#{pointer_items}</div>}
  end

  define_view :editor, :type=>'pointer' do |args|
    part_view = (c = card.rule(:input)) ? c.gsub(/[\[\]]/,'') : :list
    form.hidden_field( :content, :class=>'card-content') +
    raw(_render(part_view))
  end

  define_view :list, :type=>'pointer' do |args|
    args ||= {}
    items = args[:items] || card.item_names(:context=>:raw)
    items = [''] if items.empty?
    options_card_name = ((oc = card.options_card) ? oc.name : '*all').to_cardname.url_key

    extra_css_class = args[:extra_css_class] || 'pointer-list-ul'

    %{<ul class="pointer-list-editor #{extra_css_class}" options-card="#{options_card_name}"> } +
    items.map do |item|
      %{<li class="pointer-li"> } +
        text_field_tag( 'pointer_item', item, :class=>'pointer-item-text', :id=>'asdfsd' ) +
        link_to( 'X', '#', :class=>'pointer-item-delete' ) +
      '</li>'
    end.join("\n") +
    %{</ul><div class="add-another-div">#{link_to 'Add another','#', :class=>'pointer-item-add'}</div>}

  end

  define_view :checkbox, :type=>'pointer' do |args|
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

  define_view :multiselect, :type=>'pointer' do |args|
    options = options_from_collection_for_select(card.options,:name,:name,card.item_names)
    select_tag("pointer_multiselect", options, :multiple=>true, :class=>'pointer-multiselect')
  end

  define_view :radio, :type=>'pointer' do |args|
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

  define_view :select, :type=>'pointer' do |args|
    options = [["-- Select --",""]] + card.options.map{|x| [x.name,x.name]}
    select_tag("pointer_select", options_for_select(options, card.item_names.first), :class=>'pointer-select')
  end

  private

  def pointer_items
    typeparam = case (type=card.item_type)
      when String ; ";type:#{type}"
      when Array  ; ";type:#{type.second}"  #type spec is likely ["in", "Type1", "Type2"]
      else ""
    end
    process_content card.content.gsub(/\[\[/,"<div class=\"pointer-item item-#{@item_view}\">{{").gsub(/\]\]/,"|#{@item_view}#{typeparam}}}</div>")
  end

end
