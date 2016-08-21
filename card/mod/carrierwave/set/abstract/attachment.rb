require "carrier_wave/cardmount"

def self.included host_class
  host_class.extend CarrierWave::CardMount
end

event :select_file_revision, after: :select_action do
  attachment.retrieve_from_store!(attachment.identifier)
end

# we need a card id for the path so we have to update db_content when we have
# an id
event :correct_identifier, :finalize, on: :create do
  update_column(:db_content, attachment.db_content(mod: load_from_mod))
  expire
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

event :create_public_link, :integrate,
      on: :save,  when: proc { |c| c.unprotected? } do
  return if File.exist? public_path
  FileUtils.mkdir_p File.dirname(public_path)
  File.symlink attachment.path, public_path
end

event :remove_public_link, before: :storage_type_change,
      on: :update, when: proc { |c| !c.unprotected? } do
  return unless File.exist? public_path
  File.rm public_path
end

event :storage_type_change, :store,
      on: :update,
      when: proc { |c| c.storage_type_changed? } do
  return if storage_type.in? [:web, :coded]
  return if @new_storage_type.in? [:web, :coded]

  case storage_type
  when :cloud
    if @new_storage_type == :cloud
      move_from_cloud_to_cloud
    else
      move_from_cloud_to_local
    end
  when :protected, :unprotected
    if @new_storage_type == :cloud
      move_from_local_to_cloud
    end
  end
  #attachment.url
  #binding.pry
  # @bucket = @new_bucket
  # @storage_type = @new_storage_type
  #
  # write_identifier
end

def public_path
  Cardio.paths["public"].existent.first + file.url
end

def move_from_cloud_to_cloud
  #old_url = attachment.url
  #upload_cache_card.update_attributes! remote_file_url: url
end

def move_from_cloud_to_local
  raise Card::Error, "storage type change from :cloud to #{@new_storage_type} "\
                     "is not supported"
end

def move_from_local_to_cloud
  old_file = attachment.file
  @bucket = @new_bucket
  @storage_type = @new_storage_type
  #self.attachment.store!
  write_identifier
  self.attachment.store! old_file
end

def file_ready_to_save?
  attachment.file.present? &&
    !preliminary_upload? &&
    !save_preliminary_upload? &&
    attachment_changed?
end

def storage_type_changed?
  @new_bucket || @new_storage_type
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

def bucket= value
  if @action == :update
    @update_storage = true
    @new_bucket = value
  else
    @bucket = value
  end
end

def storage_type= value
  if @action == :update
    # we cant update the storage type directly here
    # if we do then the uploader doesn't find the file we want to update
    @update_storage = true
    @new_storage_type = value
  else
    @storage_type = value
  end
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
  @bucket ||= cloud? &&
              ((new_card? && bucket_from_config) || bucket_from_content)
end

def cloud?
  storage_type == :cloud
end

def remote_storage?
  cloud? || storage_type == :web
end

def bucket_config
  return {} unless bucket
  @bucket_config ||= Cardio.config.file_buckets[bucket].deep_symbolize_keys || {}
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
      binding.pry
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
  return unless (type = Cardio.config.file_storage)
  unless type.in? CarrierWave::FileCardUploader::STORAGE_TYPES
    raise Card::Error,
          I18n.t(:error_invalid_storage_type,
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
  storage_type ||= storage_type_from_config
  bucket ||= bucket_from_config if storage_type == :cloud
  update_attributes! storage_type: storage_type, bucket: bucket
end
