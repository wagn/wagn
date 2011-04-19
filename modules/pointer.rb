class Renderer
  define_view(:add_item, :type=>'pointer') do
    #ENGLISH
#    if !card #or !card.limit or card.limit.to_i > (index.to_i+1)
      %{<li id="#{context}-add">} +
      link_to_remote( 'Add another',
        :url=>%{javascript:urlForAddField('#{card ? card.key : ''}','#{context}')},
        :update=>%{#{context}-ul},
        :position=>:bottom
      )
#    else '' end
  end

  define_view(:checkbox, :type=>'pointer') do
    eid = context
    card.options.each do |option|
      %{<div class="pointer-checkbox"> #{
        check_box_tag "#{eid}-checkbox", option.name, card.item_names.include?(option.name),
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

  define_view(:naked, :type=>'pointer') do
    %{<div class="pointer-list"> #{
      pointer_item(slot, (item_view||'closed')) }
</div> #{ 
      link_to_function 'add/edit', %{editTransclusion(this)}, :class=>'add-edit-item'
    }} #ENGLISH
  end

  define_view(:editor, :type=>'pointer') do
    part_view = (c = card.setting('input')) ? c.gsub(/[\[\]]/,'') : 'list'
    form.hidden_field( :content, :id=>"#{context}-hidden-content") +
    render(part_view)
  end

  define_view(:field, :type=>'pointer') do |args|
    value = (args[:link]== :add ? '' : args[:link] )
    index = args[:index]
    
    result = %{<li id="#{ context }-pointer-li-#{ index }" class="pointer-li">}+
    text_field_tag("pointer[#{index}]", value, :id=>"#{context}_pointer_text_#{index}", :class=>'pointer-text') +
    cardname_auto_complete("#{context}_pointer_text_#{index}", (card && card.key))
    result += link_to_function 'X', "$('#{context}-pointer-li-#{index}').remove()", :class=>'delete'
    if args[:link]== :add
      result += render(:add_item)
    end
    result
  end

  define_view(:closed_content, :type=>'pointer') do
    %{<div class="pointer-list">} +
    pointer_item(slot, ('name'==item_view || params[:item] ? 'name' : 'link')) +
    '</div>'
  end

  define_view(:list, :type=>'pointer') do
    items = card.item_names
    items = [''] if items.empty?

    result = %{<ul id="#{context}-ul" class="pointer"> }
    items.each_with_index do |link, index| 
      result += render(:field, :link=>link, :index=>index )
    end
    result += render(:add_item, :index=>items.length ) +
    '</ul>'+

    editor_hooks( :save=>%{
      items = Element.select( $('#{context}-ul'), ".pointer-text").map(function(x){ return x.value; });
      setPointerContent('#{context}', items);
      return true;
    } )
  end

  define_view(:multiselect, :type=>'pointer') do
    options = options_from_collection_for_select(card.options,:name,:name,card.item_names)

    select_tag("#{context}-multiselect", options, :multiple=>true, :id=>"#{context}-multiselect", :class=>'pointer-multiselect') +

    editor_hooks(:save=>%{
  setPointerContent('#{context}', jQuery('##{context}-multiselect').val() );  return true;})
  end

  define_view(:radio, :type=>'pointer') do
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

  define_view(:select, :type=>'pointer') do
    eid = context
    options = [["-- Select --",""]] + card.options.map{|x| [x.name,x.name]} 
    select_tag("#{eid}-select", options_for_select(options, card.first), :id=>"#{eid}-select", :class=>'pointer-select') +

    editor_hooks(:save=>%{ setPointerContent('#{eid}', $('#{eid}-select').value); return true; })
  end
end
