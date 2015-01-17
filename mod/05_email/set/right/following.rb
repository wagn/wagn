
include Card::Set::Type::Pointer

def raw_content
  @raw_content ||= if left
      items = if left.type_id == Card::UserID
         user = left
         #all_follow_rules = Card.user_rule_cards '*all', 'follow'
         # make 'all' rule a user rule
         #all_follow_rules.map! {|card| "#{card.left.name}+#{user.name}+#{card.item_names.first}" }
         
         follow_rules = Card.user_rule_cards user.name, 'follow'
         #binding.pry
         follow_rules.map! {|card| "#{card.name}+#{card.item_names.first}" }
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
  if Env.params[:card] && (new_content=Env.params[:card][:content])
    #Card.follow_caches_expired
    #   Card.refresh_rule_cache_for_user left.id
    # Card.clear_follower_ids_cache

    Auth.as_bot do
      new_content.to_s.split(/\n+/).each do |line|
        item_name = line.gsub( /\[\[|\]\]/, '').strip.to_name
        update_follow_rule_for_following_item item_name
      end
    end
    
  end
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
     if card.left and ( card.left.id == Auth.current_id || card.left.type_id != Card::UserID)
       render_edit(args.merge(:select_list=>true, :optional_button_fieldset=>:hide))
     else
       super(args)
     end
   end
   
   view :editor do |args|
     form.hidden_field( :content, :class=>'card-content', 'no-autosave'=>true) +
        (args.delete(:select_list) ? raw(_render_select_list(args)) : super(args) )
   end
   
   view :closed_content do |args|
     ''
   end
   
   view :select_list do |args|
     list = card.item_names.map do |item_name|
        select_follow_option item_name
     end.join("\n")
     %{<div class="following-select-list">#{list}</div>}
   end
   
   view :sorted_list do |args|
     hash = Hash.new { |h,k| h[k] = [] }
     card.item_names.each do |name|
       set_name, user_name, option = split_item_name(name.to_name)
       if (set_card = Card.fetch(set_name)) && (option_card = Card.fetch(option))
         hash[option_card.codename.to_sym] << set_card.follow_label
       end
     end
     list = Card::FollowOption.codenames.map do |codename|
       if hash[codename].present?
         %{ <h1>#{Card[codename].title}</h1>
            <ul>
            #{ hash[codename].map { |entry| "<li>#{entry}</li>" }.join "\n" }
            </ul>
         }
       end
     end.compact.join "\n"
   end

   view :open_content do |args|
     render_sorted_list args
   end
  
   def follow_select_tag_option set_card, user, option
     [Card[option].form_label, set_card.to_following_item_name(:user=>user, :option=>option)]
   end
   
   def follow_select_tag selected_option, set_card, user, option_type, html_options={}
     options = Card::FollowOption.codenames(option_type).map do |codename|
       follow_select_tag_option set_card, user, codename
     end
    
     html_options.reverse_merge!(:class=>'submit-select-field', :remote=>true)  
     
     select_tag("pointer_select", options_for_select(options, selected_option), 
                  html_options) 
   end
   
   # split entry to set name, user name and selected option
   def split_item_name item_name
     [ item_name.left.to_name.left.to_name.left, item_name.left.to_name.right, item_name.right ]
   end
   

   def select_follow_option item_name
     set_name, user_name, option = split_item_name(item_name.to_name)

     
     if (set_card = Card.fetch(set_name)) && (option_card = Card.fetch(option))
       selected_option    = item_name
       selected_suboption = Card[:nothing].name
       if option_card.restrictive_option?
         selected_option    = set_card.to_following_item_name :user=>user_name, :option=>Card[:always].name
         selected_suboption = item_name
       end
         
       option_select = follow_select_tag selected_option, set_card, user_name, :main  
      # binding.pry if set_card.name = "Basic+*type"  
       suboption_select = if option_card.restrictive_option? || 
                            (option_card.codename == 'always' && set_card.right && set_card.right.codename != 'self')
           follow_select_tag selected_suboption, set_card, user_name, :restrictive#, :multiple=>true
         else
           ''
         end
         
       %{ <div class="following-select"> 
         #{ option_select }
          <label>#{set_card.follow_label}</label>  
         #{ suboption_select } 
          </div>
        }
      end
   end
   
   view :pointer_items, :tags=>:unknown_ok do |args|
     super(args.merge(:item=>:link))
   end
   
end

format(:css ) { include Card::Set::Type::Pointer::CssFormat  }
