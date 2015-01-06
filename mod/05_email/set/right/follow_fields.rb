event :follow_fields_changed, :before=>:extend do
  Card.follow_caches_expired
end