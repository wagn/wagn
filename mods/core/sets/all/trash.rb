def delete
  update_attributes :trash => true
end

def delete!
  update_attributes! :trash => true
end
  


event :pull_from_trash, :before=>:store, :on=>:create do
  if trashed_card = Card.find_by_key_and_trash(key, true)
    # a. (Rails way) tried Card.where(:key=>'wagn_bot').select(:id), but it wouldn't work.  This #select
    #    generally breaks on cards. I think our initialization process screws with something
    # b. (Wagn way) we could get card directly from fetch if we add :include_trashed (eg).
    #    likely low ROI, but would be nice to have interface to retrieve cards from trash...
    self.id = trashed_card.id
    @from_trash = true
    @new_record = false
  end
  self.trash = false
  true
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
  @subcards = children
  @subcards.each do |child|
    child.trash = true
    unless child.valid?
      child.errors.each do |field, message|
        errors.add field, "can't delete #{child.name}: #{message}"
      end
    end
  end
end

#event :delete_children, :after=>:store, :on=>:delete do
#  @children.each do |child|
#    child.save! :validate=>false
#  end
#end