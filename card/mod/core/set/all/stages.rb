attr_writer :director
delegate :act_manager, to: :director

def director
  @director ||= Card::ActManager.fetch self
end

def identify_action
  @action =
    case
    when trash     then :delete
    when new_card? then :create
    else :update
    end
end

def current_act= act
  raise Card::Error, "not allowed to override current act" if Card.current_act
  Card.current_act = act
end

def current_act
  @current_act ||= Card.current_act
end
