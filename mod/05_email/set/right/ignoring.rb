include Card::Set::Type::Pointer

event :settify_new_ignore_options, :before=>:approve, :on=>:save, :changed=>:db_content do
  temp = db_content
  item_names.each do |name|
    if option_card = Card.fetch(name) and option_card.type_id == SetID and right.codename != "self"
      temp.sub!("[[#{name}]]","[[#{name}+*self]]")
    end
  end
  db_content = temp
end

event :update_ignoramuses_after_following_changed, :after=>:store, :changed=>:db_content do #when => proc { |c| c.db_content_changed?  } do
  new_content = db_content
  db_content = db_content_was
  item_cards.each do |item|
    item.drop_ignoramus left
  end
  db_content = new_content
  item_cards.each do |item|
    item.add_ignoramus left
  end
end


format()      { include Card::Set::Type::Pointer::Format     }
format :html do
   include Card::Set::Type::Pointer::HtmlFormat
   include Card::Set::Right::Following::HtmlFormat

   view :checkbox_list do |args|
     args ||= {}
     items = args[:item_list] || card.item_names(:context=>:raw)
     items = [''] if items.empty?     
     options_card_name = (oc = card.options_card) ? oc.cardname.url_key : ':all'

     
     list = %{<div class="pointer-checkbox-sublist">} +
       '</div>' + 
       items.reject{|name| card.special_follow_option? name}.map do |name|
         if option_card = Card.fetch(name)
           checkbox_item option_card, option_card.followed?
         end
       end.join("\n") +
       %{ <ul class="pointer-list-editor pointer-sublist-ul" options-card="#{options_card_name}">
            <li class="pointer-li"> } +
              text_field_tag( 'pointer_item', '', :class=>'pointer-item-text', :id=>'asdfsd' ) +
              link_to( '', '#', :class=>'pointer-item-delete ui-icon ui-icon-circle-close' ) +
       %{   </li>
          </ul>
          <div class="add-another-div">#{link_to 'Add another','#', :class=>'pointer-item-add'}</div>
       }

     %{<div class="pointer-mixed">#{list}</div>}
     ''
   end
   
end

format(:css ) { include Card::Set::Type::Pointer::CssFormat  }



