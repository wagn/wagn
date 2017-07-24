require "active_support"
require "uri/https"
require "open-uri"
require "fileutils"

THEMES = %w[Cerulean Cosmo Cyborg Darkly Flatly Journal Litera Lumen Lux Materia Minty
            Pulse Sandstone Simplex Slate Solar Spacelab Superhero United Yeti]
           .map(&:downcase).freeze

class Theme
  SCSS_DIR = File.expand_path("../../db/migrate_core_cards/data/b4_themes", __FILE__).freeze
  THUMBNAIL_DIR = File.expand_path("../../mod/bootstrap/file", __FILE__).freeze
  BOOTSWATCH_HOST = "bootswatch.com".freeze

  def initialize name
    @theme = name
    @scss_dir =  File.join SCSS_DIR, @theme
    @thumbnail_dir = File.join THUMBNAIL_DIR, "#{@theme}_skin_image"
    ensure_dirs
  end

  def ensure_dirs
    FileUtils.mkdir_p @scss_dir
    FileUtils.mkdir_p @thumbnail_dir
  end

  def scss_path name
    File.join @scss_dir, name
  end

  def thumbnail_path
    File.join @thumbnail_dir, "image-original.png"
  end

  def uri object
    URI::HTTPS.build host: BOOTSWATCH_HOST, path: "/4-alpha/#{@theme}/#{object}"
  end
end

THEMES.each do |theme_name|
  theme = Theme.new theme_name
  %w[variables bootswatch].each do |name|
    filename = "_#{name}.scss"

    File.open(theme.scss_path(filename), "w") do |f|
      puts theme.uri(filename)
      f.puts theme.uri(filename).read
    end
  end

  File.open(theme.thumbnail_path, "w") do |f|
    f.puts theme.uri("thumbnail.png").read
  end
end
