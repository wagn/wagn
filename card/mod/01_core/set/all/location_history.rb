event :discard_deleted_locations, :after=>:store, :on=>:delete do
  Env[:controller].discard_locations_for self
  if success.target == self
    success.target = :previous
  end
end

event :save_current_location, :before=>:render_view, :on=>:read do
  Env[:controller].save_location
end