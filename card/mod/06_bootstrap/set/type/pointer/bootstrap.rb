format :html do
  view :list do |args|
    args ||= {}
    items = args[:item_list] || card.item_names(:context=>:raw)
    items = [''] if items.empty?
    options_card_name = (oc = card.options_card) ? oc.cardname.url_key : ':all'

    extra_css_class = args[:extra_css_class] || 'pointer-list-ul'

    %{<ul class="pointer-list-editor #{extra_css_class}" options-card="#{options_card_name}"> } +
    items.map do |item|
      %{<li class="pointer-li input-group"> } +
        text_field_tag( 'pointer_item', item, :class=>'pointer-item-text form-control', :id=>'asdfsd' ) +
        %{
        <span class="input-group-btn">
        <button class="pointer-item-delete glyphicon glyphicon-remove-circle btn btn-default" type="button"></button> 
        </span></li>}
    end.join("\n") +
    %{</ul><div class="add-another-div">#{link_to 'Add another','#', :class=>'pointer-item-add'}</div>}
  end
  

  view :edit do |args|
    super(args.merge(:pointer_item_class=>'form-control'))
  end
  
  view :editor do |args|
    super(args.merge(:pointer_item_class=>'form-control'))
  end
  
end