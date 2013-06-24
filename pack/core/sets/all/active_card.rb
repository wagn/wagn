# -*- encoding : utf-8 -*-

event :save_card_attributes do
  return true unless card_attr = card_attributes
warn "save card_attributes #{card_attr.inspect}"
end
