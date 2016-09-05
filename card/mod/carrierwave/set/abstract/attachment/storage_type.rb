attr_writer :bucket, :storage_type

event :storage_type_change, :store,
      on: :update, when: proc { |c| c.storage_type_changed? } do
  # carrierwave stores file if @cache_id is not nil
  attachment.cache_stored_file!
  # attachment.retrieve_from_cache!(attachment.cache_name)
  update_storage_attributes
  # next line might be necessary to move files to cloud

  # make sure that we get the new identifier
  # otherwise action_id will return wrong id for new identifier
  db_content_will_change!
  write_identifier
end

event :validate_storage_type, :validate,
      on: :save do
  if will_become_coded?
    unless mod || @new_mod
      errors.add :storage_type, "mod argument needed to save card as coded"
    end
    if codename.blank?
      errors.add :storage_type, "codename needed for storage type coded"
    end
  end
  unless known_storage_type? will_be_stored_as
    errors.add :storage_type, "unknown storage type: #{@new_storage_type}"
  end
end

event :validate_storage_type_update, :validate,
      on: :update do
  if cloud? && storage_type_changed?
    errors.add :storage_type, "moving files from cloud elsewhere "\
                              "is not supported"
  end
end

event :loose_coded_status_on_update, :initialize,
      on: :update, when: proc { |c| c.coded? } do
  return if @new_mod
  @new_storage_type ||= storage_type_from_config
end

event :update_public_link_on_create, :integrate,
      on: :create,
      when: proc { |c| c.local? } do
  update_public_link
end

event :remove_public_link_on_delete, :integrate,
      on: :delete,
      when: proc { |c| c.local? } do
  remove_public_links
end

event :update_public_link, after: :update_read_rule,
                           when: proc { |c| c.local? } do
  return if content.blank?
  if who_can(:read).include? Card[:anyone].id
    create_public_links
  else
    remove_public_links
  end
end

def create_public_links
  path = attachment.public_path
  return if File.exist? path
  FileUtils.mkdir_p File.dirname(path)
  File.symlink attachment.path, path unless File.symlink? path
  create_versions_public_links
end

def create_versions_public_links
  attachment.versions.each do |_name, version|
    next if File.symlink? version.public_path
    File.symlink version.path, version.public_path
  end
end

def remove_public_links
  symlink_dir = File.dirname attachment.public_path
  return unless Dir.exist? symlink_dir
  FileUtils.rm_rf symlink_dir
end

def will_be_stored_as
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
end

def will_become_coded?
  will_be_stored_as == :coded
end

def deprecated_mod_file?
  content && (lines = content.split("\n")) && lines.size == 4
end

def mod
  @mod ||= coded? && mod_from_content
end

def mod_from_content
  if content =~ %r{^:[^/]+/([^.]+)}
    Regexp.last_match(1) # current mod_file format
  else
    mod_from_deprecated_content
  end
end

# old format is still used in card_changes
def mod_from_deprecated_content
  return if content =~ /^\~/
  return unless (lines = content.split("\n")) && lines.size == 4
  lines.last
end

def remote_storage?
  cloud? || web?
end

def no_upload?
  storage_type_from_config == :web
end

def bucket
  @bucket ||= cloud? &&
              ((new_card? && bucket_from_config) || bucket_from_content ||
                bucket_from_config)
end

def bucket_config
  @bucket_config ||= load_bucket_config
end

def load_bucket_config
  return {} unless bucket
  bucket_config = Cardio.config.file_buckets &&
                    Cardio.config.file_buckets[bucket.to_sym]
  bucket_config &&= bucket_config.symbolize_keys
  bucket_config ||= {}
  # we don't want :attributes hash symbolized, so we can't use
  # deep_symbolize_keys
  bucket_config[:credentials] &&= bucket_config[:credentials].symbolize_keys
  ensure_bucket_config do
    load_bucket_config_from_env bucket_config
  end
end

def ensure_bucket_config
  config = yield
  unless config.present?
    raise Card::Error, "couldn't find configuration for bucket #{bucket}"
  end
  config
end

def load_bucket_config_from_env config
  config ||= {}
  CarrierWave::FileCardUploader::CONFIG_OPTIONS.each do |key|
    next if key.in? [:attributes, :credentials]
    replace_with_env_variable config, key
  end
  config[:credentials] ||= {}
  load_bucket_credentials_from_env config[:credentials]
  config.delete :credentials unless config[:credentials].present?
  config
end

def load_bucket_credentials_from_env cred_config
  cred_opt_pattern =
    Regexp.new(/^(?:#{bucket.to_s.upcase}_)?CREDENTIALS_(?<option>.+)$/)
  ENV.keys.each do |env_key|
    next unless (m = cred_opt_pattern.match(env_key))
    replace_with_env_variable cred_config, m[:option].downcase.to_sym,
                              "credentials"
  end
end

def replace_with_env_variable config, option, prefix=nil
  env_key = [prefix, option].compact.join("_").upcase
  new_value = ENV["#{bucket.to_s.upcase}_#{env_key}"] ||
              ENV[env_key]
  config[option] = new_value if new_value
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
  type = ENV["FILE_STORAGE"] || Cardio.config.file_storage
  return unless type
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
      storage_type_from_config
    end
  end
end

def update_storage_attributes
  @mod = @new_mod if @new_mod
  @bucket = @new_bucket if @new_bucket
  @storage_type = @new_storage_type
end

def storage_type_changed?
  @new_bucket || @new_storage_type || @new_mod
end

def bucket= value
  if @action == :update
    @new_bucket = value
  else
    @bucket = value
  end
end

def storage_type= value
  known_storage_type? value
  if @action == :update
    # we cant update the storage type directly here
    # if we do then the uploader doesn't find the file we want to update
    @new_storage_type = value
  else
    @storage_type = value
  end
end

def mod= value
  if @action == :update
    @new_mod = value.to_s
  else
    @mod = value.to_s
  end
end

def with_storage_options opts={}
  old_values = {}
  validate_temporary_storage_type_change opts[:storage_type]
  [:storage_type, :mod, :bucket].each do |opt_name|
    next unless opts[opt_name]
    old_values[opt_name] = instance_variable_get "@#{opt_name}"
    instance_variable_set "@#{opt_name}", opts[opt_name]
    @temp_storage_type = true
  end
  yield
ensure
  @temp_storage_type = false
  old_values.each do |key, val|
    instance_variable_set "@#{key}", val
  end
end

def temporary_storage_type_change?
  @temp_storage_type
end

def validate_temporary_storage_type_change new_storage_type=nil
  new_storage_type ||= @new_storage_type
  return unless new_storage_type
  unless known_storage_type? new_storage_type
    raise Error, "unknown storage type: #{new_storage_type}"
  end
  if new_storage_type == :coded && codename.blank?
    raise Error, "codename needed for storage type :coded"
  end
end

def known_storage_type? type=storage_type
  type.in? CarrierWave::FileCardUploader::STORAGE_TYPES
end
