
def virtual?; true end


def make_name_valid_following_entry name, user=ruled_user
  if valid_following_entry? name
    name
  else
    name = name.to_s.sub('+*follow','').to_name
    set = "#{name}+*self"                            # A              -> A+*self+always
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
          set = name                                 # A+*self        -> A+*self+always
        elsif option_card.type_id == CardtypeID
          set = "#{name}+*type"                      # Basic         -> Basic+*type+always
        elsif option_card.follow_option?
          set = "*all"
          option = name                              # created by me -> *all+created by me
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


format :html do

   view :open_content do |args|
     if card.left and Auth.signed_in?
       render_rule_editor args
     else
       followers_card = Card.fetch("#{card.cardname.left}+#{Card[:followers].name}") 
       nest followers_card, :view=>:titled, :item=>:link
     end
   end
   
   view :closed_content do |args|
     ''
   end
   
   view :editor do |args|
     form.hidden_field( :content, :class=>'card-content', 'no-autosave'=>true) +
        (args.delete(:select_list) ? raw(render_rule_editor(args)) : super(args) )
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
     
end
