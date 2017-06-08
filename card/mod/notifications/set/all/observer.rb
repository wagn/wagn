[:create, :update, :delete].each do |action|
  event "observer_#{action}".to_sym, :integrate, on: action do
    execute_card_events on: action
  end
end

event :cache_delete_card_events, :store, on: :delete do
  @card_event_cache = event_cards :on_delete
end

def execute_card_events args
  setting = "on_#{args[:on]}".to_sym
  event_cards(setting).each do |event_card|
    event_card.deliver(context: self)
  end
end

def event_cards setting
  @card_event_cache ||
    ((event_rule = rule_card(setting)) && event_rule.extended_item_cards) ||
    []
end
