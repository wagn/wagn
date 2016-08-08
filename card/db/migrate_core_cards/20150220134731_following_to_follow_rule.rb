# -*- encoding : utf-8 -*-

class FollowingToFollowRule < Card::CoreMigration
  def up
    Card.search(right: { codename: "following" }, left: { type: "user" }).each do |following_card|
      user_name = following_card.cardname.left
      following_card.item_names.each do |followed_set_name|
        set_card = Card.fetch(followed_set_name, new: {})
        if set_card.type_code != :set
          set_card = set_card.default_follow_set_card
        end
        rule = Card.fetch set_card.follow_rule_name(user_name), new: { type: "pointer" }
        rule.content = "[[*always]]"
        rule.save!
      end
    end
  end
end
