
def virtual?; true end


format :html do

   view :core do |args|
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
     rule_context = Card.fetch("#{card.left.default_follow_set_card.name}+#{Auth.current.name}+#{Card[:follow].name}", :new=>{:type=>'pointer'})
     current_follow_rule_card = card.left.rule_card(:follow, :user=>Auth.current) || rule_context
     wrap_with :div, :class=>'edit-rule' do
       subformat(current_follow_rule_card).render_edit_rule :rule_context=>rule_context, :success=>{:view=>':open', :id=>card.left.name}
     end
   end
     
end
