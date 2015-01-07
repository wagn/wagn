
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


# def add_item name
#   if (option_card = Card.fetch(name.to_name.right)) && option_card.exclusive
#     new_names = item_names.reject do |item_name|
#       item_name.to_name.left == name.to_name.left
#     end
#     self.content= "[[#{(new_names << name).reject(&:blank?)*"]]\n[["}]]"
#   else
#     super
#   end
# end





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
    if Card[option_name].exclusive
      follow_card.content = "[[#{option_name}]]"
    else
      follow_card.add_item option_name
    end
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
    
     if args.delete :checkbox_list
       args[:context] = 'Basic'
       follow_items = {} 
        if context_card = (args[:context] && Card.fetch(args[:context]))
          context_card.set_names.each do |name|
            follow_items[name] = false
          end
        end
        
       card.item_names.each do |name|
         follow_items[name.to_name.left] = name.to_name.right
       end
       
       options_card_name = (oc = card.options_card) ? oc.cardname.url_key : ':all'
       list = '<div class="pointer-checkbox-sublist">' +
         follow_items.map do |set_name, option_name|
           option_card = Card[option_name]
           set_card = Card.fetch(set_name)
           checkbox_item_second_try(option_name, set_card, option_name)
         end.join("\n") + 
         '</div>' +
         '<div style="clear:left;margin-top:60px;">' +
         add_another_second_try + "</div>"
       %{<div class="pointer-mixed">#{list}</div>}
       
     else
       super(args)
     end
   end
   
   def add_another_second_try
      options_card_name = (oc = card.options_card) ? oc.cardname.url_key : ':all'
     %{ <ul class="pointer-list-editor pointer-sublist-ul" options-card="#{options_card_name}">
          <li class="pointer-li"> } +
            text_field_tag( 'pointer_item', '', :class=>'pointer-item-text', :id=>'asdfsd' ) +
            link_to( '', '#', :class=>'pointer-item-delete ui-icon ui-icon-circle-close' ) +
     %{   </li>
        </ul>
        #{
            option_items = Card::FollowOption.codenames.map do |codename|
              option_name = Card[codename].name
              checked = false         
              %{
                <li style="list-style-type: none; float:left; margin-right:20px;">
                  #{ form.radio_button :name, option_name, :checked=>checked }
                  <span class="set-label">
                    #{ link_to_page Card.fetch(option_name).form_label, option_name, :target=>'wagn_set' }
                  </span>
                </li>
              }
            end
            %{ <ul>#{ option_items * "\n" }</ul>}
        }      
        <div class="add-another-div">#{link_to 'Add another','#', :class=>'pointer-item-add'}</div>
     }
   end
   
   def add_another
      options_card_name = (oc = card.options_card) ? oc.cardname.url_key : ':all'
     %{ <ul class="pointer-list-editor pointer-sublist-ul" options-card="#{options_card_name}">
          <li class="pointer-li"> } +
            text_field_tag( 'pointer_item', '', :class=>'pointer-item-text', :id=>'asdfsd' ) +
            link_to( '', '#', :class=>'pointer-item-delete ui-icon ui-icon-circle-close' ) +
     %{   </li>
        </ul>
        <div class="add-another-div">#{link_to 'Add another','#', :class=>'pointer-item-add'}</div>
     }
   end
   
   view :list_first do |args|
    
     if args.delete :checkbox_list
       args[:context] = 'Home'
       follow_items = Hash.new do |h,k|
          h[k] = {}
          if context_card = (args[:context] && Card.fetch(args[:context]))
            context_card.set_names.each do |name|
              h[k][name] = false
            end
          end
          h[k]
       end 
       card.item_names.each do |name|
         follow_items[name.to_name.right][name.to_name.left] = true
       end
       
       options_card_name = (oc = card.options_card) ? oc.cardname.url_key : ':all'
       list = '<div class="pointer-checkbox-sublist">' +
         Card::FollowOption.codenames.map do |option_name|
           option_card = Card[option_name]
           "<p><h2>#{option_card.title}</h2>" +
            render_checkbox_lists(args.merge(:option_name=>option_name, :item_list=>follow_items[option_card.name] )) +
            add_another +
            '</p><br>' 
         end.join("\n") + 
         '</div>' +
       %{<div class="pointer-mixed">#{list}</div>}
       
     else
       super(args)
     end
   end

   view :checkbox_list do |args|
     items = args[:item_list] || card.item_names(:context=>:raw).map{ |name| name.to_name.left }
    
     option_name = args[:option_name] || 'always'
     if items.empty?
       checkbox_item option_name, Card[:all], false
     else
       items.map do |set_name, checked| 
         if set_card = Card.fetch(set_name)
           checkbox_item option_name, set_card, checked
         end
       end.join("\n")
     end
   end
    
   
   def checkbox_item option_name, set_card, checked
     id = "pointer-checkbox-#{set_card.cardname.key}"
     description = false
     %{ <div class="pointer-checkbox"> } +
       check_box_tag( "pointer_checkbox", "#{set_card.cardname.url_key}+#{option_name}", checked, :id=>id, :class=>'pointer-checkbox-button') +
       %{ <label for="#{id}">#{set_card.follow_label}</label>
       #{ %{<div class="checkbox-option-description">#{ description }</div>} if description }
        </div>}
   end
   
   def checkbox_item_second_try selected_option_name, set_card, checked
     id = "pointer-checkbox-#{set_card.cardname.key}"
     current_set_key =  Card[:all].name
     description = false
     %{ <div class="pointer-checkbox" style="clear: both;margin-top: 50px;"> } +
       check_box_tag( "pointer_checkbox", "#{set_card.cardname.url_key}+#{selected_option_name}", checked, :id=>id, :class=>'pointer-checkbox-button') +
       %{ <label for="#{id}">#{set_card.follow_label}</label>
       #{ %{<div class="checkbox-option-description">#{ description }</div>} if description }
       <div>
       #{
         #fieldset 'options', (
           option_items = Card::FollowOption.codenames.map do |codename|
             option_name = Card[codename].name
             checked = ( option_name == selected_option_name or current_set_key && Card::FollowOption.codenames.length==1 )
             is_current = option_name.to_name.key == current_set_key
             %{
               <li style="list-style-type: none; float:left; margin-right:20px;">
                 #{ form.radio_button :name, "#{set_card}+#{option_name}", :checked=> checked }
                 <span class="set-label" #{'current-set-label' if is_current }>
                   #{ link_to_page Card.fetch(option_name).form_label, option_name, :target=>'wagn_set' }
                   #{'<em>(current)</em>' if is_current}
                 </span>
               </li>
             }
           end
           %{ <ul>#{ option_items * "\n" }</ul>}
        # ), :editor => 'set'
       }        
       
       </div>
        </div>} 
    
   end
   
   
   view :pointer_items, :tags=>:unknown_ok do |args|
     super(args.merge(:item=>:link))
   end
   
end

format(:css ) { include Card::Set::Type::Pointer::CssFormat  }
