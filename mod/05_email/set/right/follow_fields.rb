event :follow_fields_changed, :before=>:extend do
  Card::Set::All::Follow.cache_expired
end