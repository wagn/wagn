module ClassMethods
  def default_type_id
    @@default_type_id ||= Card[:all].fetch( :trait=>:default ).id
  end
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

def type_card
  Card[ type_id.to_i ]
end

def type_code # FIXME - change to "type_code"
  Card::Codename[ type_id.to_i ]
end

def type_name
  return if type_id.nil?
  type_card = Card.fetch type_id.to_i, :skip_modules=>true, :skip_virtual=>true
  type_card and type_card.name
end

def type= type_name
  self.type_id = Card.fetch_id type_name
end
