def followable?
  false
end

event :set_upload_name, :before=>:validate_name, :on=>:create do
  if name.blank?
    self.name = Card::Cache.generate_cache_id
  end
end
