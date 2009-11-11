class CardHookObserver < ActiveRecord::Observer
  observe Card
  Hook
  [:before_save, :before_create, :after_save, :after_create].each do |hookname| 
    define_method( hookname ) do |card|
      CardHook.invoke hookname, card
    end
  end
end