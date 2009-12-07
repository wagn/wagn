
Wagn::Hook::Card.register :before_save, { :type => "Set" } do |card|
  spec = Wql2::CardSpec.new(card.get_spec).spec
  card.pattern_spec_key = Wagn::Pattern.key_for_spec( spec )
end

