event :permit_codename, :validate,
      on: :update, changed: :codename do
  errors.add :codename, "only admins can set codename" unless Auth.always_ok?
  validate_uniqueness_of_codename
end

event :validate_uniqueness_of_codename do
  return unless codename.present? && errors.empty? &&
                Card.find_by_codename(codename).present?
  errors.add :codename, "codename #{codename} already in use"
end

event :validate_name, :validate,
      on: :save, changed: :name do
  validate_legality_of_name
  return if errors.any?
  validate_uniqueness_of_name
end

event :validate_uniqueness_of_name do
  # validate uniqueness of name
  condition_sql = "cards.key = ? and trash=?"
  condition_params = [cardname.key, false]
  unless new_record?
    condition_sql << " AND cards.id <> ?"
    condition_params << id
  end
  if (c = Card.find_by(condition_sql, *condition_params))
    errors.add :name, "must be unique; '#{c.name}' already exists."
  end
end

event :validate_legality_of_name do
  if name.length > 255
    errors.add :name, "is too long (255 character maximum)"
  elsif cardname.blank?
    errors.add :name, "can't be blank"
  else
    unless cardname.valid?
      errors.add :name, "may not contain any of the following characters: " \
                        "#{Card::Name.banned_array * ' '}"
    end
    # this is to protect against using a plus card as a tag
    return unless cardname.junction? && simple? && id &&
                  Auth.as_bot { Card.count_by_wql right_id: id } > 0
    errors.add :name, "#{name} in use as a tag"
  end
end

event :validate_key, after: :validate_name, on: :save do
  if key.empty?
    errors.add :key, "cannot be blank" if errors.empty?
  elsif key != cardname.key
    errors.add :key, "wrong key '#{key}' for name #{name}"
  end
end
