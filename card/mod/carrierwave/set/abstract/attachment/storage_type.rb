attr_writer :bucket, :storage_type

event :storage_type_change, :store,
      on: :update, when: proc { |c| c.storage_type_changed? } do
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
  @storage_type = @new_storage_type
  #attachment.url
  #binding.pry
  # @bucket = @new_bucket
  # @storage_type = @new_storage_type
  #
  # write_identifier
end

event :create_public_link, :integrate, on: :save,
                                       when: proc { |c| c.unprotected? } do
  return if File.exist? public_path
  FileUtils.mkdir_p File.dirname(public_path)
  File.symlink attachment.path, public_path
end

event :remove_public_link, on: :update,
                           after: :storage_type_change,
                           when: proc { |c| !c.unprotected? } do
  return unless File.exist? public_path
  FileUtils.rm public_path
end

def cloud?
  storage_type == :cloud
end

def web?
  storage_type == :web
end

def unprotected?
  storage_type == :unprotected
end

def protected?
  storage_type == :protected
end

def coded?
  @mod
end

def load_from_mod
  @mod
end

def load_from_mod= value
  @mod = value
  write_identifier
  @store_in_mod = true if value
end

def mod= value
  @mod = value
  write_identifier
  @store_in_mod = true if value
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

def remote_storage?
  cloud? || storage_type == :web
end

def bucket
  @bucket ||= cloud? &&
    ((new_card? && bucket_from_config) || bucket_from_content)
end

def mod
  @mod
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
  when /^\(/           then :cloud
  when %r{/^https?\:/} then :web
  when /^~/            then :protected
  when /^\:/           then :coded
  else :unprotected
  end
end

def update_storage_location! storage_type=nil, bucket=nil
  storage_type ||= storage_type_from_config
  bucket ||= bucket_from_config if storage_type == :cloud
  update_attributes! storage_type: storage_type, bucket: bucket
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

def storage_type_changed?
  @new_bucket || @new_storage_type
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
