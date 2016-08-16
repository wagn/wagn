require "uuid"

module ClassMethods
  def uniquify_name name, rename=:new
    return name unless Card.exists?(name)
    uniq_name = "#{name} 1"
    uniq_name.next! while Card.exists?(uniq_name)
    if rename == :old
      # name conflict resolved; original name can be used
      Card[name].update_attributes! name: uniq_name,
                                    update_referers: true
      name
    else
      uniq_name
    end
  end
end

def name= newname
  cardname = newname.to_name
  if @supercard
    @supercard.subcards.rename key, cardname.key
    @contextual_name = cardname.to_s
    relparts = cardname.parts
    if relparts.size == 2 &&
       (relparts.first.blank? || relparts.first.to_name.key == @supercard.key)
      @superleft = @supercard
    end
    cardname = cardname.to_absolute_name @supercard.name
  end

  newkey = cardname.key
  self.key = newkey if key != newkey
  update_subcard_names cardname
  write_attribute :name, cardname.s
end

def key= newkey
  was_in_cache = Card.cache.soft.delete key
  write_attribute :key, newkey
  # keep the soft cache up-to-date
  Card.write_to_soft_cache self if was_in_cache
  # reset the old name - should be handled in tracked_attributes!!
  reset_patterns_if_rule
  reset_patterns
  newkey
end

def update_subcard_names cardname
  return unless @subcards
  subcards.each do |subcard|
    # if subcard has a relative name like +C
    # and self is a subcard as well that changed from +B to A+B then
    # +C should change to A+B+C. #replace_part doesn't work in this case
    # because the old name +B is not a part of +C
    # name_to_replace =
    name_to_replace =
      if subcard.cardname.junction? &&
         subcard.cardname.parts.first.empty? &&
         cardname.parts.first.present?
        "".to_name
      else
        name
      end
    subcard.name = subcard.cardname.replace_part name_to_replace, cardname.s
  end
end

def cardname
  name.to_name
end

def autoname name
  if Card.exists? name
    autoname name.next
  else
    name
  end
end

# FIXME: use delegations and include all cardname functions
def simple?
  cardname.simple?
end

def junction?
  cardname.junction?
end

def contextual_name
  @contextual_name || name
end

def relative_name context_name=nil
  context_name ||= @supercard.cardname if @supercard
  cardname.relative_name context_name
end

def absolute_name context_name=nil
  context_name ||= @supercard.cardname if @supercard
  cardname.absolute_name context_name
end

def left *args
  case
  when simple?    then nil
  when @superleft then @superleft
  when name_changed? && name.to_name.trunk_name.key == name_was.to_name.key
    nil # prevent recursion when, eg, renaming A+B to A+B+C
  else
    Card.fetch cardname.left, *args
  end
end

def right *args
  Card.fetch(cardname.right, *args) unless simple?
end

def [] *args
  case args[0]
  when Fixnum, Range
    fetch_name = Array.wrap(cardname.parts[args[0]]).compact.join "+"
    Card.fetch(fetch_name, args[1] || {}) unless simple?
  else
    super
  end
end

def trunk *args
  simple? ? self : left(*args)
end

def tag *args
  simple? ? self : Card.fetch(cardname.right, *args)
end

def left_or_new args={}
  left(args) || Card.new(args.merge(name: cardname.left))
end

def fields
  field_names.map { |name| Card[name] }
end

def field_names parent_name=nil
  child_names parent_name, :left
end

def children
  child_names.map { |name| Card[name] }
end

def child_names parent_name=nil, side=nil
  # eg, A+B is a child of A and B
  parent_name ||= name
  side ||= parent_name.to_name.simple? ? :part : :left
  Card.search({ side => parent_name, return: :name },
              "(#{side}) children of #{parent_name}")
end

# ids of children and children's children
def descendant_ids parent_id=nil
  return [] if new_card?
  parent_id ||= id
  Auth.as_bot do
    child_ids = Card.search part: parent_id, return: :id
    child_descendant_ids = child_ids.map { |cid| descendant_ids cid }
    (child_ids + child_descendant_ids).flatten.uniq
  end
end

# children and children's children
# NOTE - set modules are not loaded
# -- should only be used for name manipulations
def descendants
  @descendants ||= descendant_ids.map { |id| Card.quick_fetch id }
end

def repair_key
  Auth.as_bot do
    correct_key = cardname.key
    current_key = key
    return self if current_key == correct_key

    if (key_blocker = Card.find_by_key_and_trash(correct_key, true))
      key_blocker.cardname = key_blocker.cardname + "*trash#{rand(4)}"
      key_blocker.save
    end

    saved =   (self.key      = correct_key) && save!
    saved ||= (self.cardname = current_key) && save!

    if saved
      descendants.each(&:repair_key)
    else
      Rails.logger.debug "FAILED TO REPAIR BROKEN KEY: #{key}"
      self.name = "BROKEN KEY: #{name}"
    end
    self
  end
rescue
  Rails.logger.info "BROKE ATTEMPTING TO REPAIR BROKEN KEY: #{key}"
  self
end

event :set_autoname, :prepare_to_validate, on: :create do
  if name.blank? && (autoname_card = rule_card(:autoname))
    self.name = autoname autoname_card.content
    # FIXME: should give placeholder in approve phase
    # and finalize/commit change in store phase
    autoname_card.refresh.update_column :db_content, name
  end
end

event :set_name, :store, changed: :name do
  Card.expire name
  Card.expire name_was
end

event :set_left_and_right, :store,
      changed: :name, on: :save do
  if cardname.junction?
    [:left, :right].each do |side|
      sidename = cardname.send "#{side}_name"
      sidecard = Card[sidename]

      # eg, renaming A to A+B
      old_name_in_way = (sidecard && sidecard.id == id)
      suspend_name(sidename) if old_name_in_way
      side_id_or_card =
        if !sidecard || old_name_in_way
          add_subcard(sidename.s)
        else
          sidecard.id
        end
      send "#{side}_id=", side_id_or_card
    end
  else
    self.left_id = self.right_id = nil
  end
end

event :rename, after: :set_name, on: :update do
  if (existing_card = Card.find_by_key_and_trash(cardname.key, true)) &&
     existing_card != self
    existing_card.name = existing_card.name + "*trash"
    existing_card.rename_without_callbacks
    existing_card.save!
  end
end

def suspend_name name
  # move the current card out of the way, in case the new name will require
  # re-creating a card with the current name, ie.  A -> A+B
  Card.expire name
  tmp_name = "tmp:" + UUID.new.generate
  Card.where(id: id).update_all(name: tmp_name, key: tmp_name)
end

event :cascade_name_changes, :finalize, on: :update, changed: :name do
  des = descendants
  @descendants = nil # reset

  des.each do |de|
    # here we specifically want NOT to invoke recursive cascades on these
    # cards, have to go this low level to avoid callbacks.
    Rails.logger.info "cascading name: #{de.name}"
    Card.expire de.name # old name
    newname = de.cardname.replace_part name_was, name
    Card.where(id: de.id).update_all name: newname.to_s, key: newname.key
    de.update_referers = update_referers
    de.refresh_references_in
    Card.expire newname
  end
end
