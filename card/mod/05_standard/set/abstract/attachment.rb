require 'carrier_wave/cardmount'

def self.included host_class
  host_class.extend CarrierWave::CardMount
end

event :select_file_revision, after: :select_action do
  attachment.retrieve_from_store!(attachment.identifier)
end

event :upload_attachment, before: :validate_name, on: :save, when: proc { |c| c.preliminary_upload? } do
  save_original_filename  # save original filename as comment in action
  write_identifier        # set db_content (needs original filename to determine extension)
  store_attachment!
  finalize_action         # create Card::Change entry for db_content
  @current_action.update_attributes! draft: true, card_id: (new_card? ? upload_cache_card.id : id)
  success << {
    target: (new_card? ? upload_cache_card : self),
    type: type_name,
    view: 'preview_editor',
    rev_id: current_action.id
  }
  abort :success
end

event :assign_attachment_on_create, after: :prepare, on: :create, when: proc { |c| c.save_preliminary_upload? } do
  if (action = Card::Action.fetch(Card::Env.params[:cached_upload]))
    upload_cache_card.selected_action_id = action.id
    upload_cache_card.select_file_revision
    assign_attachment upload_cache_card.attachment.file, action.comment
  end
end

event :assign_attachment_on_update, after: :prepare, on: :update, when: proc { |c| c.save_preliminary_upload? } do
  if (action = Card::Action.fetch(Card::Env.params[:cached_upload]))
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

# we need a card id for the path so we have to update db_content when we got an id
event :correct_identifier, after: :store, on: :create do
  update_column(:db_content,attachment.db_content(mod: load_from_mod))
  expire
end
event :save_original_filename, after: :validate_name, when: proc {|c| !c.preliminary_upload? && !c.save_preliminary_upload? && c.attachment_changed?} do

  if @current_action
    @current_action.update_attributes! comment: original_filename
  end
end

event :delete_cached_upload_file_on_create, after: :extend, on: :create, when: proc { |c| c.save_preliminary_upload? } do
  if (action = Card::Action.fetch(Card::Env.params[:cached_upload]))
    upload_cache_card.delete_files_for_action action
    action.delete
  end
  clear_upload_cache_dir_for_new_cards
end

event :delete_cached_upload_file_on_update, after: :extend, on: :update, when: proc { |c| c.save_preliminary_upload? } do
  if (action = Card::Action.fetch(Card::Env.params[:cached_upload]))
    delete_files_for_action action
    action.delete
  end
end


event :write_identifier, after: :save_original_filename do
  self.content = attachment.db_content(mod: load_from_mod)
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

# used for uploads for new cards until the new card is created
def upload_cache_card
  @upload_cache_card ||= Card["new_#{attachment_name}".to_sym ]
end


def load_from_mod= value
  @mod = value
  write_identifier
  if value
    @store_in_mod = true
  end
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
    "#{ Card.paths['files'].existent.first }/#{id}"
  else
    tmp_upload_dir
  end
end

# place for files if card doesn't have an id yet
def tmp_upload_dir action_id=nil
  "#{ Card.paths['files'].existent.first }/#{upload_cache_card.id}"
end

# place for files of mod file cards
def mod_dir
  mod = @mod || mod_file?
  Card.paths['mod'].to_a.each do |mod_path|
    dir = File.join(mod_path, mod, 'file', codename )
    if Dir.exist? dir
      return dir
    end
  end
end


def mod_file?
  if @store_in_mod
    return @mod
  # when db_content was changed assume that it's no longer a mod file
  elsif !db_content_changed? && content.present?
    case content
    when /^:[^\/]+\/([^.]+)/ ; $1     # current mod_file format
    when /^\~/               ; false  # current id file format
    else
      if lines = content.split("\n") and lines.size == 4 # old format, still used in card_changes.
        lines.last
      end
    end
  end
end


def assign_set_specific_attributes
  if @set_specific && @set_specific.present?
    self.content = nil
  end
  super
end

def clear_upload_cache_dir_for_new_cards
  Dir.entries(tmp_upload_dir).each do |filename|
    if filename =~/^\d+/
      path = File.join(tmp_upload_dir, filename )
      if older_than_five_days? File.ctime(path)
        FileUtils.rm path
      end
    end
  end
end

def older_than_five_days? time
  Time.now - time > 432000
end

def delete_files_for_action action
  with_selected_action_id(action.id) do
    FileUtils.rm attachment.file.path
    attachment.versions.each_value do |version|
      FileUtils.rm version.path
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


