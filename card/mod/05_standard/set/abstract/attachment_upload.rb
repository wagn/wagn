def followable?
  false
end

def create_versions?
  false
end

event :upload_attachment, :before=>:validate_name, :on=>:save do
  success << {
    :id => '_self',
    :type=> type_name,
    :view => 'preview_editor',
    :rev_id => current_action.id
  }
  save_original_filename
  send "store_#{attachment_name}!"
  abort :success
end

event :set_upload_name, :before=>:validate_name, :on=>:create do
  if name.blank?
    self.name = Card::Cache.generate_cache_id
  end
end
