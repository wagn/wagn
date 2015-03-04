event :update_follow_rules, :after=>:store, :on=>:save do
  defaults = item_names.map do |item|
    if ((set_card = Card.fetch item.to_name.left) && set_card.type_code == :set) 
      option_card = Card.fetch(item.to_name.right) || Card[item.to_name.right.to_sym]
      option = if option_card.follow_option?
                 option_card.name
               else
                 '*always'
               end
      [set_card, option]
    elsif ((set_card = Card.fetch sug) && set_card.type_code == :set) 
      [set_card, '*always']
    end
  end.compact
  Auth.as_bot do
    Card.search(:type=>'user').each do |user|
      defaults.each do |set_card, option|
        if (follow_rule = Card.fetch(set_card.follow_rule_name(user.name), :new=>{}))
         follow_rule.drop_item "*never"
         follow_rule.drop_item "*always"
         follow_rule.add_item option
         follow_rule.save!
        end
      end
    end
  end
  Card.follow_caches_expired
end
