require 'carrier_wave/cardmount'
extend CarrierWave::CardMount

event :write_identifier, :before=>:store do
  content = attachment.db_content
end
event :save_original_filename, :before=>:create_card_changes do
  if @current_action
    @current_action.update_attributes! :comment=>original_filename
  end
end

event :move_file_to_store_dir, :after=>:store, :on=>:create do
  if ::File.exist? tmp_store_dir
    FileUtils.mv tmp_store_dir, store_dir
  end
  if !(content =~ /^[:~]/)
    update_column(:db_content,attachment.db_content)
    expire
  end
end


def item_names(args={})  # needed for flexmail attachments.  hacky.
  [self.cardname]
end


def set_mod_source mod
  attachment.mod = mod
end

def use_mod_file! mod
  set_mod_source mod
  update_attributes! :content=>attachment.db_content
end

def original_filename
  attachment.original_filename
end


def symlink_to(prior_action_id) # create filesystem links to files from prior action
  if prior_action_id != last_action_id
    save_action_id = selected_action_id
    links = {}

    self.selected_action_id = prior_action_id
    attachment.versions.each do |name, version|
      links[name] = ::File.basename(version.path)
    end
    original = ::File.basename(attachment.path)

    self.selected_action_id = last_action_id
    attachment.versions.each do |name, version|
      ::File.symlink links[name], version.path
    end
    ::File.symlink original, attachment.path

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


