def delete
  update_attributes trash: true unless new_card?
end

def delete!
  update_attributes! trash: true unless new_card?
end

event :pull_from_trash, :prepare_to_store, on: :create do
  if (trashed_card = Card.find_by_key_and_trash(key, true))
    # a. (Rails way) tried Card.where(key: 'wagn_bot').select(:id), but it
    # wouldn't work.  This #select generally breaks on cards. I think our
    # initialization process screws with something
    # b. (Wagn way) we could get card directly from fetch if we add
    # :include_trashed (eg).
    #    likely low ROI, but would be nice to have interface to retrieve cards
    #    from trash...m
    self.id = trashed_card.id
    # update instead of create
    @from_trash = true
    @new_record = false
  end
  self.trash = false
  true
end

event :validate_delete, :validate, on: :delete do
  unless codename.blank?
    errors.add :delete, "#{name} is is a system card. (#{codename})"
  end

  undeletable_all_rules_tags =
    %w(default style layout create read update delete)
  # FIXME: HACK! should be configured in the rule

  if junction? && (l = left) && l.codename == "all" &&
     undeletable_all_rules_tags.member?(right.codename)
    errors.add :delete, "#{name} is an indestructible rule"
  end

  if account && has_edits?
    errors.add :delete, "Edits have been made with #{name}'s user account.\n" \
                        "Deleting this card would mess up our history."
  end
end

event :validate_delete_children, :prepare_to_validate, on: :delete do
  children.each do |child|
    child.trash = true
    add_subcard child
    # next if child.valid?
    # child.errors.each do |field, message|
    #   errors.add field, "can't delete #{child.name}: #{message}"
    # end
  end
end
