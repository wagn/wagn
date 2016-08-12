require "carrier_wave/cardmount"

def self.included host_class
  host_class.extend CarrierWave::CardMount
end

event :select_file_revision, after: :select_action do
  attachment.retrieve_from_store!(attachment.identifier)
end

event :upload_attachment, :prepare_to_validate,
      on: :save, when: proc { |c| c.preliminary_upload? } do
  save_original_filename  # save original filename as comment in action
  write_identifier        # set db_content
  # (needs original filename to determine extension)
  store_attachment!
  finalize_action         # create Card::Change entry for db_content

  card_id = new_card? ? upload_cache_card.id : id
  @current_action.update_attributes! draft: true, card_id: card_id
  success << {
    target: (new_card? ? upload_cache_card : self),
    type: type_name,
    view: "preview_editor",
    rev_id: current_action.id
  }
  abort :success
end

event :assign_attachment_on_create, :initialize,
      after: :assign_action, on: :create,
      when: proc { |c| c.save_preliminary_upload? } do
  if (action = Card::Action.fetch(@action_id_of_cached_upload))
    upload_cache_card.selected_action_id = action.id
    upload_cache_card.select_file_revision
    assign_attachment upload_cache_card.attachment.file, action.comment
  end
end

event :assign_attachment_on_update, :initialize,
      after: :assign_action, on: :update,
      when:  proc { |c| c.save_preliminary_upload? } do
  if (action = Card::Action.fetch(@action_id_of_cached_upload))
    uploaded_file =
      with_selected_action_id(action.id) do
        attachment.file
      end
    assign_attachment uploaded_file, action.comment
  end
end

def assign_attachment file, original_filename
  send "#{attachment_name}=", file
  write_identifier
  @current_action.update_attributes! comment: original_filename
end

# we need a card id for the path so we have to update db_content when we have
# an id
event :correct_identifier, :finalize, on: :create do
  update_column(:db_content, attachment.db_content(mod: load_from_mod))
  expire
end

def file_ready_to_save?
  attachment.file.present? &&
    !preliminary_upload? &&
    !save_preliminary_upload? &&
    attachment_changed?
end

event :save_original_filename, :prepare_to_store,
      when: proc { |c| c.file_ready_to_save? } do
  return unless @current_action
  @current_action.update_attributes! comment: original_filename
end

event :delete_cached_upload_file_on_create, :integrate,
      on: :create, when: proc { |c| c.save_preliminary_upload? } do
  if (action = Card::Action.fetch(@action_id_of_cached_upload))
    upload_cache_card.delete_files_for_action action
    action.delete
  end
  clear_upload_cache_dir_for_new_cards
end

event :delete_cached_upload_file_on_update, :integrate,
      on: :update, when: proc { |c| c.save_preliminary_upload? } do
  if (action = Card::Action.fetch(@action_id_of_cached_upload))
    delete_files_for_action action
    action.delete
  end
end

event :validate_file_exist, :validate, on: :create do
  unless attachment.file.present? || empty_ok?
    errors.add attachment_name, "is missing"
  end
end

event :write_identifier, after: :save_original_filename do
  self.content = attachment.db_content(mod: load_from_mod)
end

def item_names _args={} # needed for flexmail attachments.  hacky.
  [cardname]
end

def original_filename
  attachment.original_filename
end

def unfilled?
  !attachment.present? && !save_preliminary_upload? && !subcards.present?
end

def preliminary_upload?
  Card::Env && Card::Env.params[:attachment_upload]
end

def save_preliminary_upload?
  @action_id_of_cached_upload.present?
end

def attachment_changed?
  send "#{attachment_name}_changed?"
end

def create_versions?
  true
end

# used for uploads for new cards until the new card is created
def upload_cache_card
  @upload_cache_card ||= Card["new_#{attachment_name}".to_sym]
end

# action id of the cached upload
attr_writer :action_id_of_cached_upload

attr_reader :action_id_of_cached_upload

attr_writer :empty_ok

def empty_ok?
  @empty_ok
end

def load_from_mod= value
  @mod = value
  write_identifier
  @store_in_mod = true if value
end

def load_from_mod
  @mod
end

def store_dir
  if @store_in_mod
    mod_dir
  else
    upload_dir
  end
end

def retrieve_dir
  if mod_file?
    mod_dir
  else
    upload_dir
  end
end

# place for files of regular file cards
def upload_dir
  if id
    "#{Card.paths['files'].existent.first}/#{id}"
  else
    tmp_upload_dir
  end
end

# place for files if card doesn't have an id yet
def tmp_upload_dir _action_id=nil
  "#{Card.paths['files'].existent.first}/#{upload_cache_card.id}"
end

# place for files of mod file cards
def mod_dir
  mod = @mod || mod_file?
  Card.paths["mod"].to_a.each do |mod_path|
    dir = File.join(mod_path, mod, "file", codename)
    return dir if Dir.exist? dir
  end
end

def mod_file?
  if @store_in_mod
    return @mod
  # when db_content was changed assume that it's no longer a mod file
  elsif !db_content_changed? && content.present?
    case content
    when %r{^:[^/]+/([^.]+)} then Regexp.last_match(1) # current mod_file format
    when /^\~/               then false  # current id file format
    else
      if (lines = content.split("\n")) && (lines.size == 4)
        # old format, still used in card_changes.
        lines.last
      end
    end
  end
end

def assign_set_specific_attributes
  # reset content if we really have something to upload
  if @set_specific.present? && @set_specific[attachment_name.to_s].present?
    self.content = nil
  end
  super
end

def clear_upload_cache_dir_for_new_cards
  Dir.entries(tmp_upload_dir).each do |filename|
    if filename =~ /^\d+/
      path = File.join(tmp_upload_dir, filename)
      FileUtils.rm path if Card.older_than_five_days? File.ctime(path)
    end
  end
end

def delete_files_for_action action
  with_selected_action_id(action.id) do
    FileUtils.rm attachment.file.path
    attachment.versions.each_value do |version|
      FileUtils.rm version.path
    end
  end
end

# create filesystem links to files from prior action
def symlink_to prior_action_id
  return unless prior_action_id != last_action_id
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

def attachment_format ext
  if ext.present? && attachment && (original_ext = attachment.extension)
    if ["file", original_ext].member? ext
      original_ext
    elsif (exts = MIME::Types[attachment.content_type])
      if exts.find { |mt| mt.extensions.member? ext }
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
