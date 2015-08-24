require 'carrier_wave/cardmount'

def self.included host_class
  host_class.extend CarrierWave::CardMount
end

event :select_file_revision, :after=>:select_action do
  attachment.retrieve_from_store!(attachment.identifier)
end

event :write_identifier, :after=>:validate_name do
  if Card::Env && Card::Env.params[:cached_upload].present?
    action_id = Card::Env.params[:cached_upload]
    cached_upload = Card.new :type_id=>type_id
    cached_upload.selected_action_id = action_id
    cached_upload.select_file_revision
    send "#{attachment_name}=", cached_upload.attachment.file
  end
  self.content = attachment.db_content
end

event :save_original_filename, :after=>:write_identifier do
  if @current_action
    @current_action.update_attributes! :comment=>original_filename
  end
end

# we need a card id for the path so we have to update db_content when we got an id
event :update_db_content_with_final_path, :after=>:store, :on=>:create do
  if !(content =~ /^[:~]/)
    update_column(:db_content,attachment.db_content)
    expire
  end
end

def item_names(args={})  # needed for flexmail attachments.  hacky.
  [self.cardname]
end

def original_filename
  attachment.original_filename
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


