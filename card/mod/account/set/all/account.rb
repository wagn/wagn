module ClassMethods
  def default_accounted_type_id
    Card::UserID
  end
end

def account
  fetch trait: :account
end

def accountable?
  Card.toggle(rule(:accountable))
end

def parties
  @parties ||= (all_roles << id).flatten.reject(&:blank?)
end

def among? ok_ids
  ok_ids.any? do |ok_id|
    ok_id == Card::AnyoneID ||
      (ok_id == Card::AnyoneWithRoleID && all_roles.size > 1) ||
      parties.member?(ok_id)
  end
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
        if (rule_ids_for_party = self.class.read_rule_cache[party_id])
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
  [Card::AnyoneSignedInID] + role_ids_from_roles_trait
end

def role_ids_from_roles_trait
  Auth.as_bot do
    role_trait = fetch trait: :roles
    role_trait ? role_trait.item_ids : []
  end
end

event :generate_token do
  Digest::SHA1.hexdigest "--#{Time.zone.now.to_f}--#{rand 10}--"
end

event :set_stamper, :prepare_to_validate do
  self.updater_id = Auth.current_id
  self.creator_id = updater_id if new_card?
end
