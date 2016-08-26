attr_writer :bucket, :storage_type

event :storage_type_change, :store,
      on: :update, when: proc { |c| c.storage_type_changed? } do
  return if storage_type.in? [:web, :coded]
  return if @new_storage_type == :web

  case storage_type
  when :cloud
    if @new_storage_type == :cloud
      move_from_cloud_to_cloud
    else
      raise Card::Error, "moving files from cloud elsewhere"\
                         "is not supported"
      # move_from_cloud_to_local
    end
  when :local
    case  @new_storage_type
    when :cloud then move_from_local_to_cloud
    when :coded then move_from_local_to_coded
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

event :loose_coded_status_on_update, :initialize, on: :update,
                                     when: proc { |c| c.coded? } do
  return if @new_mod
  @new_storage_type ||= storage_type_from_config
end

def create_public_link
  url = attachment.url
  return if File.exist? url
  FileUtils.mkdir_p File.dirname(url)
  File.symlink attachment.path, url

  attachment.versions.each do |name, version|
    File.symlink version.path, version.url
  end
end

def remove_all_public_links
  return unless Dir.exist? public_file_dir
  FileUtils.rm_rf public_file_dir
end

event :update_public_link_on_create, :integrate, on: :create do
  update_public_link
end

event :update_public_link, after: :update_read_rule do
  return unless local?
  if who_can(:read).include? Card[:anyone].id
    create_public_link
  else
    remove_all_public_links
  end
end

def store_as
  @new_storage_type || storage_type
end

def cloud?
  storage_type == :cloud
end

def web?
  storage_type == :web
end

def local?
  storage_type == :local
end

def coded?
  storage_type == :coded
  # return @mod if @store_in_mod
  # # when db_content was changed assume that it's no longer a coded file
  # # unless a mod argument was passed
  # return if (db_content_changed? && !@new_mod) || !content.present?
  # mod_from_content
end

def deprecated_mod_file?
  content && (lines = content.split("\n")) && lines.size == 4
end

def mod
  @mod ||= coded? && mod_from_content
end

def mod= value
  if @action == :update
    @new_mod = value
  else
    @mod = value
  end
  # @mod = value
  # write_identifier
  # @store_in_mod = true if value
end

def mod_from_content
  if content.match(%r{^:[^/]+/([^.]+)})
    Regexp.last_match(1) # current mod_file format
  else
    mod_from_deprecated_content
  end
end

def mod_from_deprecated_content
  return if content =~ /^\~/
  return unless (lines = content.split("\n")) && lines.size == 4
  # old format, still used in card_changes
  lines.last
end

def remote_storage?
  cloud? || web?
end

def bucket
  @bucket ||= cloud? &&
              ((new_card? && bucket_from_config) || bucket_from_content ||
                bucket_from_config)
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
  when /^~/            then :local
  when /^\:/           then :coded
  else
    if deprecated_mod_file?
      :coded
    else
      raise Error, "invalid file identifier: #{content}"
    end
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
  write_identifier
  self.attachment.store! old_file
end

def move_from_local_to_coded
  unless @new_mod
    raise Card::Error, "mod needed to change storage type to :coded"
  end
  old_file = attachment.file
  @mod = @new_mod
  @storage_type = @new_storage_type
  write_identifier
  self.attachment.store! old_file
end

def storage_type_changed?
  @new_bucket || @new_storage_type
end

def bucket= value
  if @action == :update
    @new_bucket = value
  else
    @bucket = value
  end
end

def storage_type= value
  validate_storage_type value
  if @action == :update
    # we cant update the storage type directly here
    # if we do then the uploader doesn't find the file we want to update
    @new_storage_type = value
  else
    @storage_type = value
  end
end

def with_storage_options opts={}
  old_values = {}
  validate_storage_type_change opts[:storage_type]
  [:storage_type, :mod, :bucket].each do |opt_name|
    next unless opts[opt_name]
    old_values[opt_name] = instance_variable_get "@#{opt_name}"
    instance_variable_set "@#{opt_name}", opts[opt_name]
  end
  yield
ensure
  old_values.each do |key, val|
    instance_variable_set "@#{key}", val
  end
end

def validate_storage_type_change new_storage_type=nil
  new_storage_type ||= @new_storage_type
  return unless new_storage_type
  validate_storage_type new_storage_type

  if new_storage_type == :coded && codename.blank?
    raise Error, "codename needed for storage type :coded"
  end
end

def validate_storage_type type
  unless type.in? CarrierWave::FileCardUploader::STORAGE_TYPES
    raise Error, "unknown storage type: #{type}"
  end
end
