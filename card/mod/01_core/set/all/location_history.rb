event :discard_locations, :after=>:store, :on=>:delete do
  Env[:controller].discard_locations_for card
  if success.target == card
    success.target = :previous
  end
end

event :save_current_location, :before=>:render_view, :on=>:read do
  Env[:controller].save_location
end