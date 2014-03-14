module ClassMethods
  def default_accounted_type_id
    Card::UserID
  end
end

def account
  fetch :trait=>:account
end

def accountable?
  Card.toggle( rule :accountable )
end

def parties
  @parties ||= (all_roles << self.id).flatten.reject(&:blank?)
end

def among? card_with_acct
  card_with_acct.each do |auth|
    return true if parties.member? auth
  end
  card_with_acct.member? Card::AnyoneID
end

def is_own_account?
  # card is +*account card of signed_in user.
  cardname.part_names[0].key == Account.as_card.key and
  cardname.part_names[1].key == Card[:account].key
end

def read_rules
  @read_rules ||= begin
    rule_ids = []
    unless id==Card::WagnBotID # always_ok, so not needed
      ( [ Card::AnyoneID ] + parties ).each do |party_id|
        if rule_ids_for_party = self.class.read_rule_cache[ party_id ]
          rule_ids += rule_ids_for_party
        end
      end
    end
    rule_ids
  end
end

def all_roles
  @all_roles ||= 
    if id == Card::AnonID
      []
    else
      Account.as_bot do
        role_trait = fetch :trait=>:roles
        [ Card::AuthID ] + ( role_trait ? role_trait.item_ids : [] )
      end
    end
end


event :generate_token do
  Digest::SHA1.hexdigest "--#{Time.now.to_s}--#{rand 10}--" 
end

event :set_stamper, :before=>:approve do
  self.updater_id = Account.current_id
  self.creator_id = self.updater_id if new_card?
end

