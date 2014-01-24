class WagnGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  
  argument :instance
  
  def create_folders
    %w{ config lib mods script tmp log files }.each do |folder|
      directory folder
    end
  end
end
