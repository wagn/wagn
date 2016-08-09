# *DATABASE_CONTENT*
# if in mod:
#   :codename/modname.ext
# else
#   ~card_id/action_id.ext
#
# *FILE SYSTEM*
# if in mod
#   (mod_dir)/files/codename/type_code-variant.ext  (no colon on codename!)
# else
#   (files_dir)/id/action_id-variant.ext            (no tilde on id!)
#
# variant = icon|small|medium|large|original  (only for images)
#
# *URLS*
# mark.ext
# mark/revision.ext
# mark/revision-variant.ext
#
# revision = modname or action_id
#
# Examples:
# ~22/33-medium.png
# :yeti_skin/05_standard-large.png

module CarrierWave::Uploader::Versions
  private

  # put version at the end of the filename
  def full_filename for_file
    name = super(for_file)
    parts = name.split "."
    basename = [parts.shift, version_name].compact.join("-")
    "#{basename}.#{parts.join('.')}"
  end
end

class FileUploader < CarrierWave::Uploader::Base
  attr_accessor :mod
  include Card::Location

  storage :file

  def filename
    if mod_file?
      "#{model.type_code}#{extension}"
    else
      "#{action_id}#{extension}"
    end
  end

  def extension
    case
    when file && file.extension.present? then ".#{file.extension}"
    when card_content = model.content    then File.extname(card_content)
    when orig = original_filename        then File.extname(orig)
    else                                   ""
    end.downcase
  end

  # generate identifier that gets stored in the card's db_content field
  def db_content opts={}
    return "" unless file.present?
    model.load_from_mod = opts[:mod] if opts[:mod] && !model.load_from_mod
    "%s/%s" % [file_dir, url_filename(opts)]
  end

  def url_filename opts={}
    model.load_from_mod = opts[:mod] if opts[:mod] && !model.load_from_mod

    basename = if (mod = mod_file?)
                 "#{mod}#{extension}"
               else
                 "#{action_id}#{extension}"
    end
  end

  def url opts={}
    "%s/%s/%s" % [card_path(Card.config.files_web_path), file_dir,
                  full_filename(url_filename(opts))]
  end

  def file_dir
    if mod_file?
      ":#{model.codename}"
    elsif model.id
      "~#{model.id}"
    else
      "~#{model.upload_cache_card.id}"
    end
  end

  def cache_dir
    Cardio.paths["files"].existent.first + "/cache"
  end

  # Carrierwave calls store_path without argument when it stores the file
  # and with the identifier from the db when it retrieves the file
  # In our case the first part of our identifier is not part of the path
  # but we can construct the filename from db data. So we don't need the
  # identifier.
  def store_path for_file=nil
    if for_file
      retrieve_path
    else
      File.join([store_dir, full_filename(filename)].compact)
    end
  end

  def retrieve_path
    File.join([retrieve_dir, full_filename(filename)].compact)
  end

  def tmp_path
    Dir.mkdir model.tmp_upload_dir unless Dir.exist? model.tmp_upload_dir
    File.join model.tmp_upload_dir, filename
  end

  def create_versions? _new_file
    model.create_versions?
  end

  # paperclip compatibility used in type/file.rb#core (base format)
  def path version=nil
    version ? versions[version].path : super()
  end

  def original_filename
    @original_filename ||= model.selected_action &&
                           model.selected_action.comment
  end

  def store_dir
    model.store_dir
  end

  def retrieve_dir
    model.retrieve_dir
  end

  def mod_file?
    model.mod_file?
  end

  def action_id
    model.selected_content_action_id
  end
end
