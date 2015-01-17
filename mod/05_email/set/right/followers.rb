# -*- encoding : utf-8 -*-

include Card::Set::Type::Pointer


def raw_content
  if left
    items = if (left.type_id = SetID) or (left.type_id = CardtypeID)
        left.default_follow_set_card.all_user_ids_with_rule_for(:follow).map do |user_id|
          (user = Card.find(user_id)) ? user.name : nil
        end.compact
      else
        left.followers_names.join("]]\n[[")
      end
    items.present? ? "[[#{items}]]" : ''
  end
end

def virtual?; true end

format() do 
  include Card::Set::Type::Pointer::Format     
end

format(:html)  { include Card::Set::Type::Pointer::HtmlFormat }