
def cardname
  @cardname ||= name.to_name
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

def left *args
  loaded_left or if !simple?
    unless updates.for? :name and name_without_tracking.to_name.key == cardname.left_name.key
      #the ugly code above is to prevent recursion when, eg, renaming A+B to A+B+C
      #it should really be testing for any trunk
      Card.fetch cardname.left, *args
    end
  end
end

def right *args
  Card.fetch( cardname.right, *args ) if !simple?
end

def trunk *args
  simple? ? self : left( *args )
end

def tag *args
  simple? ? self : Card.fetch( cardname.right, *args )
end

def left_or_new args={}
  left args or Card.new args.merge(:name=>cardname.left)
end

def children
  Card.search( { (simple? ? :part : :left) => name } ).to_a
end

def dependents
  return [] if new_card?

  if @dependents.nil?
    @dependents =
      Account.as_bot do
        deps = children
        deps.inject(deps) do |array, card|
          array + card.dependents
        end
      end
    #Rails.logger.warn "dependents[#{inspect}] #{@dependents.inspect}"
  end
  @dependents
end

def repair_key
  Account.as_bot do
    correct_key = cardname.key
    current_key = key
    return self if current_key==correct_key

    if key_blocker = Card.find_by_key_and_trash(correct_key, true)
      key_blocker.cardname = key_blocker.cardname + "*trash#{rand(4)}"
      key_blocker.save
    end

    saved =   ( self.key  = correct_key and self.save! )
    saved ||= ( self.cardname = current_key and self.save! )

    if saved
      self.dependents.each { |c| c.repair_key }
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


event :validate_name, :before=>:approve, :on=>:save do 

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


event :set_autoname, :before=>:validate_name, :on=>:create do
  if name.blank? and autoname_card = rule_card(:autoname)
    self.name = autoname autoname_card.content
    Account.as_bot { autoname_card.refresh.update_attributes! :content=>name }   #fixme, should give placeholder on new, do next and save on create
  end
end


event :validate_key, :after=>:validate_name, :on=>:save do
  if key.empty?
    errors.add :key, "cannot be blank"
  elsif key != cardname.key
    errors.add :key, "wrong key '#{key}' for name #{name}"
  end
end

