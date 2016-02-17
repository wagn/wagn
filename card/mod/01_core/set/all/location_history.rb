event :discard_deleted_locations, in: :finalize, on: :delete do
  Env.discard_locations_for self
  success.target = :previous if success.target == self
end

event :save_current_location, before: :show_page, on: :read do
  Env.save_location self
end
