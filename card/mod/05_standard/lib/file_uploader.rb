module CarrierWave::Uploader::Versions
  private
  def full_filename(for_file)
    name = super(for_file)
    parts = name.split '.'
    basename = [parts.shift, version_name].compact.join('-')
    "#{basename}.#{parts.join('.')}"
  end
end

class FileUploader < CarrierWave::Uploader::Base
  attr_accessor :mod
  include Card::Format::Location

  storage CarrierWave::Storage::CardFile

  def path(version=nil)
    version ? versions[version].path : super()
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
    basename =
      if (mod = mod_file?)
        "#{mod}#{extension}"
      else
        filename
      end
    "%s/%s" % [card_identifier, basename]
  end

  def card_identifier
    if (mod = mod_file?)
      ":#{codecard.codename}"
    elsif model.id
      "~#{model.id}"
    else
      "#{model.key}" # FIXME what if the card has not a name yet?
    end
  end

  def url(options = {})
    "%s/%s/%s" % [card_path(Card.config.files_web_path), card_identifier, full_filename(filename)]
  end

  def tmp_store_dir
    model.tmp_store_dir
  end

  def store_dir
    model.store_dir
  end

  def mod_file?
    @mod ||= model.mod_file?
  end

  def action_id
    model.selected_content_action_id
  end

  def codecard
    model.cardname.junction? ? model.left : model
  end
end