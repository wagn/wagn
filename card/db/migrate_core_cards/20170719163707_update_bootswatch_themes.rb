# -*- encoding : utf-8 -*-

class UpdateBootswatchThemes < Card::Migration::Core
  THEMES = %w[Cerulean Cosmo Cyborg Darkly Flatly Journal Litera Lumen Lux Materia Minty
              Pulse Sandstone Simplex Slate Solar Spacelab Superhero United Yeti]
             .map(&:downcase).freeze

  def up
    THEMES.each do |theme_name|
      path = data_path "b4_themes/#{theme_name}"
      update_card "#{theme_name} skin+variables",
                  content: File.read(File.join(path, "_variables.scss")),
                  type_id: Card::ScssID
      update_card "#{theme_name} skin+style",
                  content: File.read(File.join(path, "_bootswatch.scss")),
                  type_id: Card::CssID

      theme_codename = "#{theme_name}_skin"
      ensure_card theme_name, codename: theme_codename
      ensure_card "#{thme_name}+Image", type_id: Card::ImageID
    end

    end
  end
end
