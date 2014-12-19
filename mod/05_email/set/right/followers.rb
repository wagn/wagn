# -*- encoding : utf-8 -*-

include Card::Set::Type::Pointer


def raw_content
  items = left.followers.map {|id| Card.find(id).name }.join("]]\n[[")
  items.present? ? "[[#{items}]]" : ''
end

def virtual?; true end

format() do 
  include Card::Set::Type::Pointer::Format     
end

format(:html)  { include Card::Set::Type::Pointer::HtmlFormat }