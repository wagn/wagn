module ClassMethods
  def default_accounted_type_id
    Card::UserID
  end
end

def account
  fetch trait: :account
end

def accountable?
  Card.toggle(rule :accountable)
end

def parties
  @parties ||= (all_roles << id).flatten.reject(&:blank?)
end

def among? ok_ids
  ok_ids.each do |ok_id|
    return true if parties.member? ok_id
  end
  ok_ids.member? Card::AnyoneID
end

def own_account?
  # card is +*account card of signed_in user.
  cardname.part_names[0].key == Auth.as_card.key &&
    cardname.part_names[1].key == Card[:account].key
end

def read_rules
  @read_rules ||= begin
    rule_ids = []
    unless id == Card::WagnBotID # always_ok, so not needed
      ([Card::AnyoneID] + parties).each do |party_id|
        if rule_ids_for_party = self.class.read_rule_cache[party_id]
          rule_ids += rule_ids_for_party
        end
      end
    end
    rule_ids
  end
end

def all_roles
  @all_roles ||= (id == Card::AnonymousID ? [] : fetch_roles)
end

def fetch_roles
  Auth.as_bot do
    role_trait = fetch trait: :roles
    next [Card::AnyoneSignedInID] unless role_trait
    [Card::AnyoneSignedInID] + role_trait.item_ids
  end
end

event :generate_token do
  Digest::SHA1.hexdigest "--#{Time.zone.now.to_f}--#{rand 10}--"
end

event :set_stamper, :prepare_to_validate do
  self.updater_id = Auth.current_id
  self.creator_id = updater_id if new_card?
end
