require 'mini_magick'

class ImageUploader < FileUploader
  include CarrierWave::MiniMagick

  def path(version=nil)
    (version && version != :original) ? versions[version].path : super()
  end

  version :icon, :if=>:create_versions?, :from_version=>:small do
    process :resize_and_pad => [16,16]
  end
  version :small, :if=>:create_versions?, :from_version=>:medium do
    process :resize_to_fit => [75,75]
  end
  version :medium, :if=>:create_versions? do
    process :resize_to_fit => [200,200]
  end
  version :large, :if=>:create_versions? do
    process :resize_to_fit => [500,500]
  end

  def identifier
    full_filename(super())
  end
  # add 'original' if no version is given
  def full_filename(for_file)
    name = super(for_file)
    if version_name
      name
    else
      parts = name.split '.'
      "#{parts.shift}-original.#{parts.join('.')}"
    end
  end


end