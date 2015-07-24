require 'mini_magick'
class ImageUploader < FileUploader
  include CarrierWave::MiniMagick

  version :icon do
    process :resize_to_fill => [16,16]
  end
  version :small do
    process :resize_to_fill => [75,75]
  end
  version :medium do
    process :resize_to_fill => [200,200]
  end
  version :large do
    process :resize_to_fill => [500,500]
  end

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