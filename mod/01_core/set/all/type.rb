
module ClassMethods
  def default_type_id
    @@default_type_id ||= Card[:all].fetch( :trait=>:default ).type_id
  end
end

def type_card
  return if type_id.nil?
  Card.fetch type_id.to_i, :skip_modules=>true
end

def type_code
  Card::Codename[ type_id.to_i ]
end

def type_name
  type_card.try :name
end

def type_cardname
  type_card.try :cardname
end

def type= type_name
  self.type_id = Card.fetch_id type_name
end

def get_type_id args={}
  return if args[:type_id] # type_id was set explicitly.  no need to set again.
  
  type_id = case
    when args[:type_code]
      if code=args[:type_code]
        Card::Codename[code] || ( c=Card[code] and c.id)
      end
    when args[:type]
      Card.fetch_id args[:type]
    else :noop
    end

  case type_id
  when :noop
  when false, nil
    errors.add :type, "#{args[:type] || args[:type_code]} is not a known type."
  else
    return type_id
  end

  if name && t=template
    reset_patterns #still necessary even with new template handling?
    t.type_id
  end
end


event :validate_type_change, :before=>:approve, :on=>:update, :changed=>:type_id do
  if c = dup and c.action == :create and !c.valid?
    errors.add :type, "of #{ name } can't be changed; errors creating new #{ type_id }: #{ c.errors.full_messages * ', ' }"
  end
end

event :validate_type, :before=>:approve, :changed=>:type_id do    
  if !type_name
    errors.add :type, "No such type"
  end
  
  if rt = structure and rt.assigns_type? and type_id!=rt.type_id
    errors.add :type, "can't be changed because #{name} is hard templated to #{rt.type_name}"
  end
end

event :reset_type_specific_fields, :after=>:store do
  Auth.as_bot do
    Card.search :left=>{ :left=>type_name }, :right=>{:codename=>'type_plus_right'} do |set_card|
      set_card.reset_set_patterns
    end
  end
end

#    Card.search :left_plus=>[ type_name, :right_plus=>{:codename=>'type_plus_right'}] do |right_anchor|
#      Card["#{lef}"]
#      set_card.reset_set_patterns
#    end
  
