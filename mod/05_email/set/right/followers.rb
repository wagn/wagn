# -*- encoding : utf-8 -*-

include Card::Set::Type::Pointer

# def item_names args={}
#   left.followers.map {|id| Card.find(id).name }
# end

def raw_content
  items = left.followers.map {|id| Card.find(id).name }.join("]]\n[[")
  items.present? ? "[[#{items}]]" : ''
end

def virtual?; true end

format()       do 
  include Card::Set::Type::Pointer::Format     
  # view :raw do |args|
  #   items = card.item_names.join("]]\n[[")
  #   items.present? ? "[[#{items}]]" : ''
  # end
end

format(:html)  { include Card::Set::Type::Pointer::HtmlFormat }