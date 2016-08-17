require "carrier_wave/cardmount"

def self.included host_class
  host_class.extend CarrierWave::CardMount
end

event :select_file_revision, after: :select_action do
  attachment.retrieve_from_store!(attachment.identifier)
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


event :validate_file_exist, :validate, on: :create do
  unless attachment.file.present? || empty_ok?
    errors.add attachment_name, "is missing"
  end
end

event :write_identifier, after: :save_original_filename do
  self.content = attachment.db_content(mod: load_from_mod)
end

def store_dir
  @store_in_mod ? mod_dir : upload_dir
end

def retrieve_dir
  mod_file? ? mod_dir : upload_dir
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

def attachment_changed?
  send "#{attachment_name}_changed?"
end

def create_versions?
  true
end

attr_writer :empty_ok
attr_writer :bucket, :storage_type

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

# place for files of regular file cards
def upload_dir
  id ? "#{files_base_dir}/#{id}" : tmp_upload_dir
end

# place for files of mod file cards
def mod_dir
  mod = @mod || mod_file?
  Card.paths["mod"].to_a.each do |mod_path|
    dir = File.join(mod_path, mod, "file", codename)
    return dir if Dir.exist? dir
  end
end

def files_base_dir
  bucket ? bucket_config[:subdirectory] : Card.paths["files"].existent.first
end

def bucket
  @bucket ||= bucket? &&
              ((new_card? && bucket_from_config) || bucket_from_content)
end

def bucket?
  storage_type == :bucket
end

def bucket_config
  return {} unless bucket
  @bucket_config ||= Cardio.config.file_buckets[bucket] || {}
end

def bucket_from_content
  return unless content
  content.match(/^\((?<bucket>[^)]+)\)/) { |m| m[:bucket] }
end

def bucket_from_config
  Cardio.config.file_default_bucket ||
    (Cardio.config.file_buckets && Cardio.config.file_buckets.keys.first)
end

def mod_file?
  return @mod if @store_in_mod
  # when db_content was changed assume that it's no longer a mod file
  return if db_content_changed? || !content.present?
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

def assign_set_specific_attributes
  # reset content if we really have something to upload
  if @set_specific.present? && @set_specific[attachment_name.to_s].present?
    self.content = nil
  end
  super
end

def delete_files_for_action action
  with_selected_action_id(action.id) do
    attachment.file.delete
    attachment.versions.each_value do |version|
      version.delete
      #FileUtils.rm version.path
    end
  end
end

# create filesystem links to files from prior action
def rollback_to action
  update_attributes! revision(action).merge(empty_ok: true)
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

def storage_type
  @storage_type ||=
    new_card? ? storage_type_from_config : storage_type_from_content
end

def storage_type_from_config
  return unless (type = Cardio.file_storage)
  unless type.in? CarrierWave::FileCardUploader.STORAGE_TYPES
    raise Card::Error,
          I18n.t(:error_invalid_storage_option,
                 scope: "mod.carrierwave.set.abstract.attachment",
                 type: type)
  end
  type
end

def storage_type_from_content
  case content
  when /^\(/        then :cloud
  when %r{^http://} then :web
  when /^~/         then :protected
  when /^\:/        then :coded
  else :unprotected
  end
end

def update_storage_location! storage_type=nil, bucket=nil

end