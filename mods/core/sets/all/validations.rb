event :recaptcha, :before=>:approve do
  if !@nested_edit                      and
      Wagn::Env[:recaptcha_on]          and
      Card.toggle( rule :captcha )      and
      num = Wagn::Env[:recaptcha_count] and
      num < 1
      
    Wagn::Env[:recaptcha_count] = num + 1
    Wagn::Env[:controller].verify_recaptcha :model=>self or self.error_status = 449
  end
end


event :validate_name, :before=>:approve do 
  if new_card? && name.blank?
    if autoname_card = rule_card(:autoname)
      Account.as_bot do
        autoname_card = autoname_card.refresh
        self.name = autoname( autoname_card.content )
        autoname_card.content = name  #fixme, should give placeholder on new, do next and save on create
        autoname_card.save!
      end
    end
  end

  cdname = name.to_name
  if cdname.blank?
    errors.add :name, "can't be blank"
  elsif updates.for?(:name)
    #Rails.logger.debug "valid name #{card.name.inspect} New #{name.inspect}"

    unless cdname.valid?
      errors.add :name,
        "may not contain any of the following characters: #{ Card::Name.banned_array * ' ' }"
    end
    # this is to protect against using a plus card as a tag
    if cdname.junction? and simple? and id and Account.as_bot { Card.count_by_wql :right_id=>id } > 0
      errors.add :name, "#{name} in use as a tag"
    end

    # validate uniqueness of name
    condition_sql = "cards.key = ? and trash=?"
    condition_params = [ cdname.key, false ]
    unless new_record?
      condition_sql << " AND cards.id <> ?"
      condition_params << id
    end
    if c = Card.find(:first, :conditions=>[condition_sql, *condition_params])
      errors.add :name, "must be unique; '#{c.name}' already exists."
    end
  end
end


event :validate_key, :after=>:validate_name do
  if key.empty?
    errors.add :key, "cannot be blank"
  elsif key != cardname.key
    errors.add :key, "wrong key '#{key}' for name #{name}"
  end
end

event :validate_content, :before=>:approve do
  if new_card? && !updates.for?(:content)
    self.content = content #this is not really a validation.  is the double card.content meaningful?  tracked attributes issue?
  end

  if updates.for? :content
    reset_patterns_if_rule
    send :further_validate_content, content
  end
end

event :detect_conflict, :before=>:approve do
  if !new_card? && current_revision_id_changed? && current_rev_id.to_i != current_revision_id_was.to_i
    @current_revision_id = current_revision_id_was
    errors.add :conflict, "changes not based on latest revision"
    @error_view = :conflict
  end
end

event :validate_type, :before=>:approve do
  # validate on update
  if updates.for?(:type_id) and !new_card?
    if !validate_type_change
      errors.add :type, "of #{ name } can't be changed; errors changing from #{ type_name }"
    end
    if c = dup and c.type_id_without_tracking = type_id and c.id = nil and !c.valid?
      errors.add :type, "of #{ name } can't be changed; errors creating new #{ type_id }: #{ c.errors.full_messages * ', ' }"
    end
  end

  # validate on update and create
  if updates.for?(:type_id) or new_record?
    # invalid to change type when type is hard_templated
    if rt = hard_template and rt.assigns_type? and type_id!=rt.type_id
      errors.add :type, "can't be changed because #{name} is hard templated to #{rt.type_name}"
    end
  end
end

