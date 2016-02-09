def director
  @director ||= Card.fetch_director self
end

def director= dir
  @director = dir
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
  if Card.current_act
    fail Card::Error, 'not allowed to override current act'
  end
  Card.current_act = act
end

def current_act
  @current_act ||= Card.current_act
end

def stage
  director.stage
end
