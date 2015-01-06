
include Card::Set::Type::Pointer

event :update_follow_rules, :before=>:extend, :on=>:save, :changed=>:db_content do
  if left
  #  Card.refresh_rule_cache_for_user left.id
   # Card.clear_follower_ids_cache
   @follow_rule_cards = {}
   Card.follow_caches_expired
   new_names = item_names
   old_names = item_names :content=>(db_content_was || '')
   (new_names-old_names).each do |item|                                                                         
     add_follow_rule item
   end
   (old_names-new_names).each do |item|
     drop_follow_rule item
   end
   @follow_rule_cards.each do |name,card|
     Auth.as_bot do
       if card.content.present?
         card.save!
       else
         card.delete!
       end
     end
   end
  end
end

event :normalize_follow_options, :before=>:approve, :on=>:save, :changed=>:db_content do
  self.content = item_names.map do |item_name| 
    valid_name = make_name_valid_following_entry item_name.to_name
    "[[#{valid_name}]]"
  end.join("\n")
end

def make_name_valid_following_entry name
  if valid_following_entry? name
    name
  elsif name.junction? && 
        (right_card = Card.fetch(name.right)) && right_card.follow_option? &&
        (left_card = Card.fetch(name.left)) && left_card.type_id != SetID 
                               
      if left_card.type_id == CardtypeID
        "#{name.left}+*type+#{name.right}"                       # Basic+never    -> Basic+*type+never
      else
        "#{name.left}+*self+#{name.right}"                       # A+never        -> A+*self+never
      end
  elsif ( option_card = Card.fetch(name) )
      if option_card.type_id == SetID  
        "#{name}+always"                                         # A+*self        -> A+*self+always
      elsif option_card.type_id == CardtypeID
        "#{name}+*type+always"                                   # Basic"         -> Basic+*type+always
      elsif option_card.follow_option?
        "*all+#{name}"                                           # created by me" -> *all+created by me
      else
        "#{name}+*self+always"                                   # A              -> A+*self+always
      end
  else
    "#{name}+*self+always"                                       # A              -> A+*self+always
  end  
end

def valid_following_entry? name
  name = name.to_name
  name.junction? && (left_card = Card.fetch(name.left))   && left_card.type_id == SetID &&
                    (right_card = Card.fetch(name.right)) && right_card.follow_option?
end


def follow_rule_card item_name
  if set_name = item_name.to_name.left
    @follow_rule_cards ||= {}
    follow_rule_name = "#{set_name}+#{Card[:follow].name}+#{left.name}"
    @follow_rule_cards[follow_rule_name] ||= Card.fetch follow_rule_name, :new=>{:type_id=>PointerID}
  end
end


def add_follow_rule item_name
  if follow_card = follow_rule_card(item_name)
    option_name = item_name.to_name.right
    follow_card.add_item option_name
  end
end

def drop_follow_rule item_name
  if follow_card = follow_rule_card(item_name)
    option_name = item_name.to_name.right
    follow_card.drop_item option_name
  end
end



format()      { include Card::Set::Type::Pointer::Format     }
format :html do
   include Card::Set::Type::Pointer::HtmlFormat

   view :open do |args|
     if card.left and card.left.id == Auth.current_id 
       render_edit(args.merge(:checkbox_list=>true))
     else
       super(args)
     end
   end
   
   view :list do |args|
     follow_items = Hash.new {|h,k| h[k] = [] }
     card.item_names.each do |name|
       follow_items[name.to_name.right] << name.to_name.left
     end
     if args.delete :checkbox_list
       "Following:<p>" +
       render_checkbox_lists(args.merge(:item_list=>follow_items['always'])) +
       '</p>Ignoring:<p>' +
      render_checkbox_lists(args.merge(:item_list=>follow_items['never'])) +
       '</p>'
     else
       super(args)
     end
   end

   view :checkbox_list do |args|
     args ||= {}
     items = args[:item_list] || card.item_names(:context=>:raw)
     items = [''] if items.empty?     
     options_card_name = (oc = card.options_card) ? oc.cardname.url_key : ':all'

     
     list = %{<div class="pointer-checkbox-sublist">} +
       Card::FollowOption.names.map do |name|
         option_card = Card[name]
         checked = card.item_names.include?(option_card.name)
         checkbox_item option_card, checked
       end.join("\n") + 
       '</div>' + 
       items.map do |name|   #FIXME
         if option_card = Card.fetch(name)
           checkbox_item option_card, true
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
   end
   
   
   

   def checkbox_item option_card, checked
     id = "pointer-checkbox-#{option_card.cardname.key}"
     description = false
     %{ <div class="pointer-checkbox"> } +
       check_box_tag( "pointer_checkbox", option_card.cardname.url_key, checked, :id=>id, :class=>'pointer-checkbox-button') +
       %{ <label for="#{id}">#{option_card.follow_label}</label>
       #{ %{<div class="checkbox-option-description">#{ description }</div>} if description }
        </div>}
   end
   
   
   view :pointer_items, :tags=>:unknown_ok do |args|
     super(args.merge(:item=>:link))
   end
   
end

format(:css ) { include Card::Set::Type::Pointer::CssFormat  }
