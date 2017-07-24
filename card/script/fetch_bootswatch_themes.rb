require "active_support"
require "uri/https"
require "open-uri"
require "fileutils"

THEMES = %w[Cerulean Cosmo Cyborg Darkly Flatly Journal Litera Lumen Lux Materia Minty
            Pulse Sandstone Simplex Slate Solar Spacelab Superhero United Yeti]
           .map(&:downcase).freeze

class Theme
  STORE_DIR = File.expand_path("../../db/migrate_core_cards/data/b4_themes", __FILE__).freeze
  BOOTSWATCH_HOST = "bootswatch.com".freeze
  VERSION = "4-alpha"

  def initialize name
    @theme = name
    @store_dir =  File.join STORE_DIR, @theme
    FileUtils.mkdir_p @store_dir
  end

  def store_path filename
    File.join @store_dir, filename
  end

  def uri object
    URI::HTTPS.build host: BOOTSWATCH_HOST, path: "/#{VERSION}/#{@theme}/#{object}"
  end
end

THEMES.each do |theme_name|
  theme = Theme.new theme_name
  %w[_variables.scss _bootswatch.scss thumbnail.png].each do |filename|
    File.open(theme.store_path(filename), "w") do |f|
      puts theme.uri(filename)
      f.puts theme.uri(filename).read
    end
  end
end
