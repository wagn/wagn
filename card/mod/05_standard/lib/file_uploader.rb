
class FileUploader < CarrierWave::Uploader::Base
  extend Card::Format::Location

  storage :file

  def store_dir
    if (mod = mod_file?)
      # generalize this to work with any mod (needs design)
      codecard = model.cardname.junction? ? model.left : model
      "#{ Cardio.gem_root}/mod/#{mod}/file/#{codecard.codename}"
    elsif model.id
      "#{ Card.paths['files'].existent.first }/#{model.id}"
    else
      tmp_store_dir
    end
  end

  def tmp_store_dir
    "#{ Card.paths['files'].existent.first }/#{model.key}"
  end

  def mod_file?
    if model.content.present? && !model.content =~ /^(\d+)\.([^.]+)/
      return $1
    end
  end

  def filename
    if super
      @name ||=
        if model.mod_file?
          "#{model.type_code}#{File.extname(super)}"
        else
          "#{action_id}#{File.extname(super)}"
        end
    end
  end

  def identifier
    if @filename =~ /^(\d+)(?:-(#{versions.keys.join '|'}))?\.([^.]+)/
      "~#{model.id}/#{$1}.#{$3}"
    elsif  model.codename
      ":#{codename}/"
    end
  end

  # def version_prefix
  #   model.type_id==Card::FileID || @style.blank? ? '' : "#{@style}-"
  # end

  def action_id
    model.selected_content_action_id
  end

  # def url arg={}
  #   'myurl'
  # end
  #
  # def system_path at, style
  #   card = model
  #   if mod = card.attach_mod
  #     # generalize this to work with any mod (needs design)
  #     codecard = card.cardname.junction? ? card.left : card
  #     "#{ Cardio.gem_root}/mod/#{mod}/file/#{codecard.codename}/#{size at, style}#{card.type_code}"
  #   else
  #     "#{ Card.paths['files'].existent.first }/#{card.id}/#{size at, style}#{action_id at, style}"
  #   end
  # end
  #
  # def web_dir at, style_name
  #   card_path Card.config.files_web_path
  # end
  #
  # def basename at, style_name
  #   at.instance.name.to_name.url_key
  # end
  #
  # def size(at, style_name)
  #   at.instance.type_id==Card::FileID || style_name.blank? ? '' : "#{style_name}-"
  # end
  #
  # def action_id(at, style_name)
  #   at.instance.selected_content_action_id
  # end


end