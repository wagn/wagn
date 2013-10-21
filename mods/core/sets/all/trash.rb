def delete
  update_attributes :trash => true
end

def delete!
  update_attributes! :trash => true
end
  

#reset_patterns_if_rule saving=true

event :validate_delete, :before=>:approve, :on=>:delete do
  if !codename.blank?
    errors.add :delete, "#{name} is is a system card. (#{codename})"
  end
  if account && Card::Revision.find_by_creator_id( self.id )
    errors.add :delete, "Edits have been made with #{name}'s user account.\n  Deleting this card would mess up our revision records."
  end
end

event :validate_delete_children, :after=>:approve, :on=>:delete do
  @cards = children
  cards.each do |child|
    child.trash = true
    unless child.valid?
      errors.add(:delete, "can't delete child #{child.name}: #{child.errors[:delete]}")  #add permission errors too?
    end
  end
end

event :delete_children, :after=>:store, :on=>:delete do
  cards.each do |child|
    child.save
    if child.errors.any?
      child.errors.each do |field, err|
        errors.add card.name, err
      end
      raise ActiveRecord::Rollback, "broke commit_subcards"
    end
  end
end