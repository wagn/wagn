class Renderer
  view(:add_item, :type=>'pointer') do
    #ENGLISH
    if !card or !card.limit or card.limit.to_i > (index.to_i+1)
      %{<li id="#{eid}-add"> #{
        link_to_remote 'Add another', :url=>%{javascript:urlForAddField('#{
          card ? card.key : ''}','#{eid}')}, :update=>%{#{eid}-ul}, :position=>:bottom }}
    end
  end

  view(:checkbox, :type=>'pointer') do
    eid = context
    card.options.each do |option|
      %{<div class="pointer-checkbox"> #{
        check_box_tag "#{eid}-checkbox", option.name, card.items.include?(option.name),
      { :id=>"#{eid}-checkbox-#{option.key}", :class=>'pointer-checkbox-button' } }
  <span class="pointer-checkbox-label">
    <span class="checkbox-option-name"><%= option.name %></span>
    #{description = card.option_text(option.name) ?  %{
      <div class="checkbox-option-description">#{ description }</div>} : '' }
  </span>
</div>}
    end * "\n" + editor_hooks(:save=>%{
  boxes = jQuery('input[name=#{eid}-checkbox]:checked')
  vals = boxes.map(function(i,n){ return jQuery(n).val(); }).get();
  setPointerContent('#{eid}', vals );  
  return true;
})
  end

  view(:naked, :type=>'pointer') do
    %{<div class="pointer-list"> #{
      pointer_item(slot, (item_view||'closed')) }
</div> #{ 
      link_to_function 'add/edit', %{editTransclusion(this)}, :class=>'add-edit-item'
    }} #ENGLISH
  end

  view(:editor, :type=>'pointer') do
    part_view = (c = card.setting('input')) ? c.gsub(/[\[\]]/,'') : 'list'
    form.hidden_field :content, :id=>"#{context}-hidden-content" +
    render(part_view)
  end

  view(:field, :type=>'pointer') do
    value = (link== :add ? '' : link )
    result = %{
<li id="#{ eid }-pointer-li-#{ index }" class="pointer-li">
#{ text_field_tag "pointer[#{index}]", value, :id=>"#{eid}_pointer_text_#{index}", :class=>'pointer-text'} } +
    cardname_auto_complete("#{eid}_pointer_text_#{index}", (card && card.key))
    unless card && card.limit==1
      result += link_to_function 'X', "$('#{eid}-pointer-li-#{index}').remove()", :class=>'delete'
    end
    if link== :add
      result += render_add_item
    end
    result
  end

  view(:closed_content, :type=>'pointer') do
    %{<div class="pointer-list">} +
    pointer_item(slot, ('name'==item_view || params[:item] ? 'name' : 'link')) +
    '</div>'
  end

  view(:list, :type=>'pointer') do
    eid = context 
    items = card.items
    items = [''] if items.empty?

    %{<ul id="#{eid}-ul" class="pointer"> #{
      items.each_with_index do |link, index| 
        render_field( :eid=>eid, :index=>index )
  end*"\n"} #{
      render_add_item( :eid=>eid, :index=>items.length )
  }
</ul>

#{ editor_hooks :save=>%{
  items = Element.select( $('#{eid}-ul'), ".pointer-text").map(function(x){ return x.value; });
  setPointerContent('#{eid}', items);
  return true;
} }}
  end

  view(:multiselect, :type=>'pointer') do
    eid = context
    options = options_from_collection_for_select(card.options,:name,:name,card.items)

    select_tag("#{eid}-multiselect", options, :multiple=>true, :id=>"#{eid}-multiselect", :class=>'pointer-multiselect') +

    editor_hooks(:save=>%{
  setPointerContent('#{eid}', jQuery('##{eid}-multiselect').val() );  return true;})
  end

  view(:radio, :type=>'pointer') do
    eid = context
    %{
<div class="pointer-radio-list"> #{
      card.options.each do |option|
        %{
  <div class="pointer-radio">#{
          radio_button_tag "#{eid}-radio", option.name, option.name==card.first,
       :id=>"#{eid}-radio-#{option.key}", :class=>'pointer-radio-button'}
    <span class="pointer-radio-label">
      <span class="radio-option-name">#{ option.name }</span>#{
        description = card.option_text(option.name) ? %{
          <div class="radio-option-description">#{ description }</div>
          } : '' }
    </span>
  </div>
}
      end * "\n"}
</div>#{
    editor_hooks :save=>%{
  setPointerContent('#{eid}', jQuery('input[name=#{eid}-radio]:checked').val() ); return true; }
    }}
  end

  view(:select, :type=>'pointer') do
    eid = context
    options = [["-- Select --",""]] + card.options.map{|x| [x.name,x.name]} 
    select_tag("#{eid}-select", options_for_select(options, card.first), :id=>"#{eid}-select", :class=>'pointer-select') +

    editor_hooks(:save=>%{ setPointerContent('#{eid}', $('#{eid}-select').value); return true; })
  end
end
