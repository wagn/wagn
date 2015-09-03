require 'carrier_wave/cardmount'

def self.included host_class
  host_class.extend CarrierWave::CardMount
end

event :select_file_revision, :after=>:select_action do
  attachment.retrieve_from_store!(attachment.identifier)
end

event :upload_attachment, :before=>:validate_name, :on=>:save, :when=>proc { |c| c.preliminary_upload? } do
  success << {
    :target => (new_card? ? upload_cache_card : '_self'),
    :type=> type_name,
    :view => 'preview_editor',
    :rev_id => current_action.id
  }
  @current_action.update_attributes! :draft => true, :card_id => (new_card? ? upload_cache_card.id : id)
  save_original_filename
  send "store_#{attachment_name}!"
  abort :success
end


event :assign_attachment_on_create, :after=>:prepare, :on=>:create do
  if save_preliminary_upload? && (action = Card::Action.fetch(Card::Env.params[:cached_upload]))
    upload_cache_card.selected_action_id = action.id
    upload_cache_card.select_file_revision
    set_attachment upload_cache_card.attachment.file, action.comment
    action.delete # TODO: delete files too
  end
end

event :assign_attachment_on_update, :after=>:prepare, :on=>:update do
  if save_preliminary_upload? && (action = Card::Action.fetch(Card::Env.params[:cached_upload]))
    uploaded_file =
       with_selected_action_id(action.id) do
         attachment.file
       end
    set_attachment uploaded_file, action.comment
    action.delete
  end
end

def set_attachment file, original_filename
  send "#{attachment_name}=", file
  @current_action.update_attributes! :comment=>original_filename
  write_identifier
end

# we need a card id for the path so we have to update db_content when we got an id
event :correct_identifier, :after=>:store, :on=>:create do
  update_column(:db_content,attachment.db_content)
  expire
end


event :save_original_filename, :after=>:validate_name, :when => proc {|c| !c.preliminary_upload? && !c.save_preliminary_upload? && c.attachment_changed?} do
  if @current_action
    @current_action.update_attributes! :comment=>original_filename
  end
end

event :write_identifier, :after=>:save_original_filename do
  self.content = attachment.db_content
end


def upload_cache_card
  @upload_cache_card ||= Card["new_#{attachment_name}".to_sym ]
end

def tmp_store_dir action_id=nil
  "#{ Card.paths['files'].existent.first }/#{upload_cache_card.id}"
end

def item_names(args={})  # needed for flexmail attachments.  hacky.
  [self.cardname]
end

def original_filename
  attachment.original_filename
end

def preliminary_upload?
  Card::Env && Card::Env.params[:attachment_upload]
end

def save_preliminary_upload?
  Card::Env.params[:cached_upload].present?
end

def attachment_changed?
  send "#{attachment_name}_changed?"
end

def create_versions?
  true
end

def assign_set_specific_attributes
  if @set_specific && @set_specific.present?
    self.content = nil
  end
  super
end

def clear_upload_tmp_dir
  Dir.entries(tmp_store_dir).each do |filename|
    if filename =~/^\d+/
      path = File.join(tmp_store_dir, filename )
      older_than_five_days = ( DateTime.now - File.ctime(path) > 432000)
      if older_than_five_days
        FileUtils.rm path
      end
    end
  end
end

def symlink_to(prior_action_id) # create filesystem links to files from prior action
  if prior_action_id != last_action_id
    save_action_id = selected_action_id
    links = {}

    self.selected_action_id = prior_action_id
    attachment.versions.each do |name, version|
      links[name] = version.store_path
    end
    original = attachment.store_path

    self.selected_action_id = last_action_id
    attachment.versions.each do |name, version|
      ::File.symlink links[name], version.store_path
    end
    ::File.symlink original, attachment.store_path

    self.selected_action_id = save_action_id
  end
end

def attachment_format(ext)
  if ext.present? && attachment && original_ext=attachment.extension
    if['file', original_ext].member? ext
      original_ext
    elsif exts = MIME::Types[attachment.content_type]
      if exts.find {|mt| mt.extensions.member? ext }
        ext
      else
        exts[0].extensions[0]
      end
    end
  end
rescue => e
  Rails.logger.info "attachment_format issue: #{e.message}"
  nil
end


