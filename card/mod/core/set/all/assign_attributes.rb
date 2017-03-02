
def assign_attributes args={}
  args = prepare_assignment_args args

  assign_with_subcards args do
    assign_with_set_modules args do
      params = prepare_assignment_params args
      super params
    end
  end
end

def assign_set_specific_attributes
  return unless @set_specific.present?
  @set_specific.each_pair do |name, value|
    send "#{name}=", value
  end
end

def extract_subcard_args! args
  subcards = args.delete("subcards") ||  args.delete(:subcards) || {}
  if (subfields = args.delete("subfields") || args.delete(:subfields))
    subfields.each_pair do |key, value|
      subcards[cardname.field(key)] = value
    end
  end
  args.keys.each do |key|
    subcards[key] = args.delete(key) if key =~ /^\+/
  end
  subcards
end

protected

def prepare_assignment_params args
  params = ActionController::Parameters.new(args)
  params.permit!
  params
end

def prepare_assignment_args args
  return {} unless args
  args = args.stringify_keys
  normalize_type_attributes args
  stash_set_specific_attributes args
  args
end

def assign_with_set_modules args
  set_changed = args["name"] || args["type_id"]
  return yield unless set_changed

  refresh_set_modules { yield }
end

def assign_with_subcards args
  subcard_args = extract_subcard_args! args
  yield
  # name= must come before process subcards
  return unless subcard_args.present?
  subcards.add subcard_args
end

def refresh_set_modules
  reload_set_modules = @set_mods_loaded
  yield
  reset_patterns
  include_set_modules if reload_set_modules
end

def stash_set_specific_attributes args
  @set_specific = {}
  Card.set_specific_attributes.each do |key|
    @set_specific[key] = args.delete(key) if args[key]
  end
end

def normalize_type_attributes args
  new_type_id = extract_type_id! args unless args.delete("skip_type_lookup")
  args["type_id"] = new_type_id if new_type_id
end

def extract_type_id! args={}
  type_id =
    case
    when args["type_id"]
      id = args.delete("type_id").to_i
      # type_id can come in as 0,'' or nil
      id.zero? ? nil : id
    when args["type_code"]
      Card.fetch_id args.delete("type_code").to_sym
    when args["type"]
      Card.fetch_id args.delete("type")
    else
      return nil
    end

  unless type_id
    errors.add :type, "#{args[:type] || args[:type_code]} is not a known type."
  end
  type_id
end
