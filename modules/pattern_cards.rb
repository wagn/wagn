
Wagn::Hook::Card.register :before_save, { :type => "Pattern" } do |card|
  card.pattern_spec_key = Wagn::Pattern.key_for_spec( JSON.parse( card.content ).symbolize_keys )
end

## DEBUG
File.open("#{RAILS_ROOT}/log/wagn.log","w") do |f|
  f.write "loaded pattern cards"
end

