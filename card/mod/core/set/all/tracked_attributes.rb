def assign_attributes args={}
  if args
    args = args.stringify_keys
    @set_specific = {}
    Card.set_specific_attributes.each do |key|
      @set_specific[key] = args.delete(key) if args[key]
    end

    new_type_id = extract_type_id! args unless args.delete("skip_type_lookup")
    subcard_args = extract_subcard_args! args
    args["type_id"] = new_type_id if new_type_id
    reset_patterns
  end
  params = ActionController::Parameters.new(args)
  params.permit!
  super params
  return unless args && subcard_args.present?
  # name= must come before process subcards
  subcards.add subcard_args
end

def assign_set_specific_attributes
  return unless @set_specific.present?
  @set_specific.each_pair do |name, value|
    send "#{name}=", value
  end
end

protected

def extract_subcard_args! args
  subcards = args.delete("subcards") || {}
  if (subfields = args.delete("subfields"))
    subfields.each_pair do |key, value|
      subcards[cardname.field(key)] = value
    end
  end
  args.keys.each do |key|
    subcards[key] = args.delete(key) if key =~ /^\+/
  end
  subcards
end

def extract_type_id! args={}
  type_id =
    case
    when args["type_id"]
      id = args.delete("type_id").to_i
      # type_id can come in as 0,'' or nil
      id == 0 ? nil : id
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

event :set_content, :store, on: :save do
  self.db_content = content || "" # necessary?
  self.db_content = Card::Content.clean!(db_content) if clean_html?
  @selected_action_id = @selected_content = nil
  clear_drafts
  reset_patterns_if_rule true
end
