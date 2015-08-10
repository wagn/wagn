=begin

DATABASE_CONTENT
if in mod:
  :codename/modname.ext
else
  ~card_id/action_id.ext


FILE SYSTEM
if in mod
  (mod_dir)/files/codename/type_code-variant.ext  (no colon on codename!)
else
  (files_dir)/id/action_id-variant.ext            (no tilde on id!)

variant = icon|small|medium|large|original


URLS
mark.ext
mark/revision.ext
mark/revision-variant.ext

revision = modname or action_id

Examples:
~22/33-medium.png
:yeti_skin/05_standard-large.png

=end


module CarrierWave::Uploader::Versions
  private

  # put version at the end of the filename
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

  storage :file

  def filename
    if mod_file?
      "#{model.type_code}#{extension}"
    else
      "#{action_id}#{extension}"
    end
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
  def db_content(args={})
    basename =
      if (args[:mod])
        "#{args[:mod]}#{extension}"
      else
        filename
      end
    "%s/%s" % [file_dir, basename]
  end

  def url(options = {})
    "%s/%s/%s" % [card_path(Card.config.files_web_path), file_dir, full_filename(filename)]
  end

  def file_dir
    if (mod = mod_file?)
      ":#{model.codename}"
    elsif model.id
      "~#{model.id}"
    else
      "#{model.key}" # FIXME what if the card has not a name yet?
    end
  end

  def cache_dir
    Wagn.root.join 'tmp/uploads'
  end

  # Carrierwave usually store the filename as identifier in the database
  # and retrieve_from_store! calls store_path with the identifier from the db
  # In our case the first part of our identifier is not part of the path
  # but we construct the filename from db data. So we don't need the identifier.
  # We can just call store_path always with the filename
  def store_path(for_file=filename) #
    super(filename)
  end

  # paperclip compatibility used in type/file.rb#core (base format)
  def path(version=nil)
    version ? versions[version].path : super()
  end

  def original_filename
    @original_filename || model.selected_action.comment
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
end