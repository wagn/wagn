def director
  @director ||= Card::StageDirector.fetch self
end

def director= dir
  @director = dir
end

def stage_index stage
  case stage
  when Symbol then return STAGE_INDEX[stage]
  when Integer then return stage
  else
    raise Card::Error, "not a valid stage: #{stage}"
  end
end

def run_stage_on_subcards stage
  puts "#{name}: #{phase} stage on subcards"
  subcards.catch_up_to_stage STAGE_INDEX[stage]
  handle_subcard_errors
end

def identify_action
  @action =
    case
    when trash     then :delete
    when new_card? then :create
    else :update
    end
end

def initialize_act
  identify_action
  reset_patterns
  include_set_modules
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


