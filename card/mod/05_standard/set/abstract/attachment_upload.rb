def followable?
  false
end

def create_versions?
  false
end

event :upload_attachment, :before=>:validate_name, :on=>:save do
  binding.pry
  Env.params[:success] = {
    :id => '_self',
:type=> 'file',
    :view => 'preview_editor',
    :action_id => current_action.id
  }
  abort :success
end

event :set_upload_name, :before=>:validate_name, :on=>:create do
  if name.blank?
    self.name = Card::Cache.generate_cache_id
  end
end
