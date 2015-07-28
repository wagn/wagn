require 'mini_magick'
class ImageUploader < FileUploader
  include CarrierWave::MiniMagick

  def initialize model=nil, mounted_as=nil
    super
    versions[:original] = self
  end

  version :icon, :from_version=>:small do
    process :resize_to_fill => [16,16]
  end
  version :small, :from_version=>:medium do
    process :resize_to_fill => [75,75]
  end
  version :medium do
    process :resize_to_fill => [200,200]
  end
  version :large do
    process :resize_to_fill => [500,500]
  end

  def full_filename(for_file)
    name = super(for_file)
    version_name ? name : "original-#{name}"
  end


end