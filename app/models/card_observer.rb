class CardObserver < ActiveRecord::Observer
  observe Card
  Wagn::Hook
  [:before_save, :before_create, :after_save, :after_create].each do |hookname| 
    define_method( hookname ) do |card|
      Wagn::Hook::Card.invoke hookname, card
    end
  end
end