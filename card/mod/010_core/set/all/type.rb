
module ClassMethods
  def default_type_id
    @@default_type_id ||= Card[:all].fetch(trait: :default).type_id
  end
end

def type_card
  return if type_id.nil?
  Card.quick_fetch type_id.to_i
end

def type_code
  Card::Codename[type_id.to_i]
end

def type_name
  type_card.try :name
end

def type_name_or_default
  type_card.try(:name) || Card.quick_fetch(Card.default_type_id).name
end

def type_cardname
  type_card.try :cardname
end

def type= type_name
  self.type_id = Card.fetch_id type_name
end

def get_type_id_from_structure
  return unless name && (t = template)
  reset_patterns # still necessary even with new template handling?
  t.type_id
end

event :validate_type_change, :validate, on: :update, changed: :type_id do
  if (c = dup) && c.action == :create && !c.valid?
    errors.add :type, "of #{name} can't be changed; errors creating new " \
                      "#{type_id}: #{c.errors.full_messages * ', '}"
  end
end

event :validate_type, :validate, changed: :type_id do
  errors.add :type, "No such type" unless type_name

  if (rt = structure) && rt.assigns_type? && type_id != rt.type_id
    errors.add :type, "can't be changed because #{name} is hard templated " \
                      "to #{rt.type_name}"
  end
end
