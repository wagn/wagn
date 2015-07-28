module CarrierWave::Uploader::Versions
  private
  def full_filename(for_file)
    [version_name, super(for_file)].compact.join('-')  # use "-" instead of "_" for backwards compatibility
  end
end

class FileUploader < CarrierWave::Uploader::Base
  attr_accessor :mod
  include Card::Format::Location

  storage :file

  def store_dir
    if (mod = mod_file?) # generalize this to work with any mod (needs design)
      "#{ Cardio.gem_root}/mod/#{mod}/file/#{codecard.codename}"
    elsif model.id
      "#{ Card.paths['files'].existent.first }/#{model.id}"
    else
      tmp_store_dir
    end
  end

  def store_path(for_file=filename)
    if for_file.include? '/' # store_path was called with identifier. Use filename instead
      super(filename)
    else
      super(for_file)
    end
  end

  def filename
    @name ||=
      if mod_file?
        "#{model.type_code}#{extension}"
      else
        "#{action_id}#{extension}"
      end
  end

  def original_filename
    @original_filename || model.selected_action.comment
  end

  def extension
    if file && file.extension.present?
      ".#{file.extension}"
    elsif original_filename
      File.extname(original_filename)
    else model.content
      File.extname(model.content)
    end
  end

  # the identifier gets stored in the card's db_content field
  def identifier
    if (mod = mod_file?)
      ":#{codecard.codename}/#{mod}#{extension}"
    elsif model.id
      "~#{model.id}/#{filename}"
    else
      "#{model.key}/#{filename}" # FIXME what if the card has not a name yet?
    end
  end

  def url(options = {})
    card_identifier =
      if mod_file?
        ":#{codecard.codename}"
      elsif model.id
        "~#{model.id}"
      else
        "#{model.key}"
      end
    "%s/%s/%s" % [card_path(Card.config.files_web_path), card_identifier, full_filename(filename)]
  end


  def tmp_store_dir
    "#{ Card.paths['files'].existent.first }/#{model.key}"
  end

  def mod_file?
    @mod ||=
      if model.content.present? && model.content =~ /^:[^\/]+\/([^.]+)/
        $1
      end
  end

  def action_id
    # we can't use selected_content_action_id here because when we create a new file content
    # the content field hasn't changed yet when we generate the filename
    model.selected_action_id || (model.current_action && model.current_action.id) || model.last_content_action_id
  end

  def codecard
    model.cardname.junction? ? model.left : model
  end
end