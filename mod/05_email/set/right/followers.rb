# -*- encoding : utf-8 -*-

include Card::Set::Type::Pointer

def item_names
  left.followers.map {|id| Card.find(id).name }
end


format()  { include Card::Set::Type::Pointer::Format     }
format()  { include Card::Set::Type::Pointer::HtmlFormat }