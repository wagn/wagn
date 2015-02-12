
include Card::Set::Type::Pointer

def raw_content
  @raw_content ||= if left
      items = if left.type_id == Card::UserID
         user = left
         #all_follow_rules = Card.user_rule_cards '*all', 'follow'
         # make 'all' rule a user rule
         #all_follow_rules.map! {|card| "#{card.left.name}+#{user.name}+#{card.item_names.first}" }

         follow_rules = Card.user_rule_cards user.name, 'follow'
         #follow_rules.map! {|card| "#{card.name}+#{card.item_names.first}" }
         follow_rules.map! {|card| card.name }
         #all_follow_rules +
         follow_rules

      else
        user = if Auth.signed_in?
         Auth.current.name
        else
          Card[:all].name # TODO does this really work?
        end
        left.related_follow_set_cards.map do |set_card|
          set_card.to_following_item_name(:user=>user)
        end
      end.join("]]\n[[")
      items.present? ? "[[#{items}]]" : ''
    else
      ''
    end
end

def ruled_user
  if left.type_id == Card::UserID
    left
  elsif Auth.signed_in?
    Auth.current
  else
    Card[:all]  # dangerous
  end
end

def virtual?; true end

def update_follow_rule_for_following_item item_name
  valid_name = item_name # make_name_valid_following_entry(item_name).to_name, ruled_user
  rule_name   = valid_name.left
  option_name = valid_name.right
  Auth.as_bot do
    if option_name != Card[:nothing].name 
      follow_rule_card = Card.fetch rule_name, :new=>{:type_id=>PointerID}
      follow_rule_card.update_attributes! :content=>"[[#{option_name}]]"
    elsif (follow_rule_card = Card.fetch(rule_name))
      follow_rule_card.delete!
    end
  end
end

event :update_follow_rules, :after=>:extend, :on=>:save do
  # if Env.params[:card] && (new_content=Env.params[:card][:content])
  #   #Card.follow_caches_expired
  #   #   Card.refresh_rule_cache_for_user left.id
  #   # Card.clear_follower_ids_cache
  #
  #   Auth.as_bot do
  #     new_content.to_s.split(/\n+/).each do |line|
  #       item_name = line.gsub( /\[\[|\]\]/, '').strip.to_name
  #       update_follow_rule_for_following_item item_name
  #     end
  #   end
  #
  # end
end

# event :normalize_follow_options, :before=>:approve, :on=>:save, :changed=>:db_content do
#   self.content = item_names.map do |item_name|
#     valid_name = make_name_valid_following_entry item_name.to_name
#     "[[#{valid_name}]]"
#   end.join("\n")
# end

def make_name_valid_following_entry name, user=ruled_user
  if valid_following_entry? name
    name
  else
    name = name.to_s.sub('+*follow','').to_name
    set = "#{name}+*self"                             # A              -> A+*self+always
    option = "always"
    
    if name.junction? &&  (right_card = Card.fetch(name.right)) && right_card.follow_option? &&
                          (left_card = Card.fetch(name.left)) && left_card.type_id != SetID 
                          
      option = name.right
      set =  if left_card.type_id == CardtypeID
          "#{name.left}+*type"                       # Basic+never    -> Basic+*type+never
        else
          "#{name.left}+*self"                       # A+never        -> A+*self+never
        end
    elsif ( option_card = Card.fetch(name) )
        if option_card.type_id == SetID  
          set = name                                              # A+*self        -> A+*self+always
        elsif option_card.type_id == CardtypeID
          set = "#{name}+*type"                                   # Basic         -> Basic+*type+always
        elsif option_card.follow_option?
          set = "*all"
          option = name                                           # created by me -> *all+created by me
        end
     end
   end 
   
   "#{set}+#{Card[:follow].name}+#{user.name}+#{option}"                                       
end

def valid_following_entry? name
  name = name.to_name
  name.junction? && (left_card = Card.fetch(name.left))   && left_card.follow_rule_card? &&
                    (right_card = Card.fetch(name.right)) && right_card.follow_option?
end


format() { include Card::Set::Type::Pointer::Format   }

 
format :html do
   include Card::Set::Type::Pointer::HtmlFormat

   view :open do |args|
     if card.left and Auth.signed_in?
       render_rule_editor args
     else
       followers_card = Card.fetch("#{card.cardname.left}+#{Card[:followers].name}") #, :new=>{})
       nest followers_card
     end
   end
   
   
   
   view :editor do |args|
     form.hidden_field( :content, :class=>'card-content', 'no-autosave'=>true) +
        (args.delete(:select_list) ? raw(render_rule_editor(args)) : super(args) )
        # raw(_render_select_list(args)) 
   end
   
   view :rule_editor do |args|
     rule_context = Card.fetch("#{card.left.follow_set_card.name}+#{Auth.current.name}+#{Card[:follow].name}", :new=>{:type=>'pointer'})
     current_follow_rule_card = card.left.rule_card(:follow, :user=>Auth.current) || rule_context
     frame do
       wrap_with :div, :class=>'edit-rule' do
         subformat(current_follow_rule_card).render_edit_rule :rule_context=>rule_context, :success=>{:view=>':open', :id=>card.left.name}
       end
     end
   end
     
   view :closed_content do |args|
     ''
   end
   
   view :delete_list do |args|

     args ||= {}
     items = args[:item_list] || card.item_names(:context=>:raw)
     options_card_name = (oc = card.options_card) ? oc.cardname.url_key : ':all'

     extra_css_class = args[:extra_css_class] || 'pointer-list-ul'
     frame do
       %{<ul class="pointer-list-editor #{extra_css_class}" options-card="#{options_card_name}"> } +
       items.map do |item|
         card_form :action=>:delete, :id=>item do
           %{<li class="pointer-li"> } +
           link_to( '', '#', :class=>'item-card-delete ui-icon ui-icon-circle-close' ) +
             Card.fetch(item).item_cards.first.label + ' ' +
             Card.fetch(item).rule_set.follow_label +
           '</li>'
         end
       end.join("\n") +
       %{</ul>}
     end

   end
   
   
   view :pointer_items, :tags=>:unknown_ok do |args|
     super(args.merge(:item=>:link))
   end
   
end

format(:css ) { include Card::Set::Type::Pointer::CssFormat  }
