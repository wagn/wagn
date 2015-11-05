require 'uuid'

module ClassMethods
  def uniquify_name name, rename=false
    return name unless Card.exists?(name)
    uniq_name = "#{name} 1"
    while Card.exists?(uniq_name)
      uniq_name.next!
    end
    return uniq_name unless rename

    Card[name].update_attributes! name: uniq_name,
                                  update_referencers: true
    # name conflict resolved; original name can be used
    name
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
  if key != newkey
    self.key = newkey
    # reset the old name - should be handled in tracked_attributes!!
    reset_patterns_if_rule
    reset_patterns
  end
  subcards.each do |subcard|
    subcard.name = subcard.cardname.replace_part name, newname
  end

  write_attribute :name, cardname.s
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
  if !context_name && @supercard
    context_name = @supercard.cardname
  end
  cardname.relative_name(context_name)
end

def absolute_name context_name=nil
  if !context_name && @supercard
    context_name = @supercard.cardname
  end
  cardname.absolute_name(context_name)
end

def left *args
  return if simple?
  @superleft || begin
    unless name_changed? &&
           name.to_name.trunk_name.key == name_was.to_name.key
      # prevent recursion when, eg, renaming A+B to A+B+C
      Card.fetch cardname.left, *args
    end
  end
end

def right *args
  Card.fetch(cardname.right, *args) if !simple?
end

def [] *args
  case args[0]
  when Fixnum, Range
    fetch_name = Array.wrap(cardname.parts[args[0]]).compact.join '+'
    Card.fetch(fetch_name, args[1] || {}) if !simple?
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

def children
  children_names.map { |name| Card[name] }
end

def children_names parent_name=nil
  # eg, A+B is a child of A and B
  field = simple? ? :part : :left
  parent_name ||= name
  Card.search field => parent_name, return: :name
end

def descendant_names parent_name=nil
  puts "finding descendants of #{parent_name}"
  return [] if new_card?
  parent_name ||= name
  if @descendant_names.nil?
    @descendant_names =
      Auth.as_bot do
        deps = children_names parent_name
        deps.inject(deps) do |array, childname|
          array + descendant_names( childname )
        end
      end
  end
  @descendant_names
end

def descendants
  # children and children's children
  # NOTE - set modules are not loaded
  # -- should only be used for name manipulations
  descendant_names.map { |name| Card.quick_fetch name }
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

    saved =   (self.key      = correct_key) && self.save!
    saved ||= (self.cardname = current_key) && self.save!

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

event :permit_codename, before: :approve, on: :update, changed: :codename do
  errors.add :codename, 'only admins can set codename' unless Auth.always_ok?
end

event :validate_unique_codename, after: :permit_codename do
  if codename.present? && errors.empty? &&
     Card.find_by_codename(codename).present?
    errors.add :codename, "codename #{codename} already in use"
  end
end

event :validate_name, before: :approve, on: :save do
  cdname = name.to_name
  if name.length > 255
    errors.add :name, 'is too long (255 character maximum)'
  elsif cdname.blank?
    errors.add :name, "can't be blank"
  elsif name_changed?
    # Rails.logger.debug "valid name #{card.name.inspect} New #{name.inspect}"

    unless cdname.valid?
      errors.add :name, 'may not contain any of the following characters: ' \
                        "#{ Card::Name.banned_array * ' ' }"
    end
    # this is to protect against using a plus card as a tag
    if cdname.junction? && simple? && id &&
       Auth.as_bot { Card.count_by_wql right_id: id } > 0
      errors.add :name, "#{name} in use as a tag"
    end

    # validate uniqueness of name
    condition_sql = 'cards.key = ? and trash=?'
    condition_params = [cdname.key, false]
    unless new_record?
      condition_sql << ' AND cards.id <> ?'
      condition_params << id
    end
    if (c = Card.find_by(condition_sql, *condition_params))
      errors.add :name, "must be unique; '#{c.name}' already exists."
    end
  end
end

event :set_autoname, before: :validate_name, on: :create do
  if name.blank? && (autoname_card = rule_card(:autoname))
    self.name = autoname autoname_card.content
    # FIXME: should give placeholder on new, do next and save on create
    Auth.as_bot { autoname_card.refresh.update_attributes! content: name }
  end
end

event :validate_key, after: :validate_name, on: :save do
  if key.empty?
    errors.add :key, 'cannot be blank' if errors.empty?
  elsif key != cardname.key
    errors.add :key, "wrong key '#{key}' for name #{name}"
  end
end

event :set_name, before: :store, changed: :name do
  Card.expire name
  Card.expire name_was
  if cardname.junction?
    [:left, :right].each do |side|
      sidename = cardname.send "#{side}_name"
      # warn "sidename #{name} / #{name_was} / #{cardname},
      # #{side}: #{sidename}"
      sidecard = Card[sidename]

      # eg, renaming A to A+B
      old_name_in_way = (sidecard && sidecard.id == id)
      suspend_name(sidename) if old_name_in_way
      send "#{side}_id=", begin
        if !sidecard || old_name_in_way
          Card.create! name: sidename, supercard: self
        else
          sidecard
        end.id
      end
    end
  else
    self.left_id = self.right_id = nil
  end
end

event :rename, after: :set_name, on: :update do
  if (existing_card = Card.find_by_key_and_trash(cardname.key, true)) &&
     existing_card != self
    existing_card.name = existing_card.name + '*trash'
    existing_card.rename_without_callbacks
    existing_card.save!
  end
end

def suspend_name name
  # move the current card out of the way, in case the new name will require
  # re-creating a card with the current name, ie.  A -> A+B
  Card.expire name
  tmp_name = 'tmp:' + UUID.new.generate
  Card.where(id: id).update_all(name: tmp_name, key: tmp_name)
end

event :cascade_name_changes, after: :store, on: :update, changed: :name do
  # Rails.logger.info "------------------- #{name_was} CASCADE #{self.name} " \
  #                   " -------------------------------------"
  # handle strings from cgi
  self.update_referencers = false if update_referencers == 'false'
  Card::Reference.update_on_rename self, name, self.update_referencers

  des = descendants
  @descendant_names = nil # reset

  des.each do |de|
    # here we specifically want NOT to invoke recursive cascades on these
    # cards, have to go this low level to avoid callbacks.
    Rails.logger.info "cascading name: #{de.name}"
    Card.expire de.name # old name
    newname = de.cardname.replace_part name_was, name
    Card.where(id: de.id).update_all name: newname.to_s, key: newname.key
    Card::Reference.update_on_rename de, newname, update_referencers
    Card.expire newname
  end
  execute_referencers_update(des) if update_referencers
end

def execute_referencers_update descendants
  Auth.as_bot do
    [name_referencers(name_was) + descendants.map(&:referencers)]
      .flatten.uniq.each do |card|
      # FIXME:  using 'name_referencers' instead of plain 'referencers' for self
      # because there are cases where trunk and tag
      # have already been saved via association by this point and therefore
      # referencers misses things
      # eg.  X includes Y, and Y is renamed to X+Z.  When X+Z is saved, X is
      # first updated as a trunk before X+Z gets to this point.
      # so at this time X is still including Y, which does not exist.
      # therefore #referencers doesn't find it, but name_referencers(old_name)
      # does.
      # some even more complicated scenario probably breaks on the descendants,
      # so this probably needs a more thoughtful refactor
      # aligning the dependent saving with the name cascading

      Rails.logger.debug "------------------ UPDATE REFERER #{card.name} " \
                         '------------------------'
      unless card == self || card.structure
        card = card.refresh
        card.db_content = card.replace_references name_was, name
        card.save!
      end
    end
  end
end
