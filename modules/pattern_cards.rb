
Wagn::Hook::Card.register :before_save, { :type => "Pattern" } do |card|
  card.pattern_spec_key = Wagn::Pattern.key_for_spec( JSON.parse( card.content ).symbolize_keys )
end

