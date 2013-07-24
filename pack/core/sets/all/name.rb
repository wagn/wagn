
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
  if !simple?
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

def dependents
  return [] if new_card?

  if @dependents.nil?
    @dependents =
      Account.as_bot do
        deps = Card.search( { (simple? ? :part : :left) => name } ).to_a
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

