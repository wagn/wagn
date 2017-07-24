# -*- encoding : utf-8 -*-

class UpdateBootswatchThemes < Card::Migration::Core
  THEMES = %w[Cerulean Cosmo Cyborg Darkly Flatly Journal Litera Lumen Lux Materia Minty
              Pulse Sandstone Simplex Slate Solar Spacelab Superhero United Yeti]
             .map(&:downcase).freeze

  def up
    THEMES.each do |theme_name|
      Card.exists?("#{theme_name} skin") ? update_skin(theme_name) : create_skin(theme_name)
    end
  end

  def resource_path theme_name, resource
    data_path "b4_themes/#{theme_name}/#{resource}"
  end

  def create_skin theme_name
    Card.create! name: "#{theme_name.sub('_', ' ')} skin",
                 codename: "#{theme_name}_skin",
                 type_id: Card::SkinID,
                 content: "[[themeless bootstrap skin]]\n[[+bootswatch theme]]",
                 subcards: {
                   "+variables" => {
                     type_id: Card::ScssID,
                     content: File.read(
                       resource_path(theme_name, "_variables.scss")
                     )
                   },
                   "+style" => {
                     type_id: Card::ScssID,
                     content: File.read(
                       resource_path(theme_name, "_bootswatch.scss")
                     )
                   },
                   "+Image" => {
                     type_id: Card::ImageID,
                     codename: "#{theme_name}_skin_image",
                     mod: :bootstrap, storage_type: :coded,
                     image: File.open(
                       resource_path(theme_name, "thumbnail.png")
                     )
                   }
                 }
  end

  def update_skin theme_name
    skin_name = "#{theme_name} skin"
    update_card "#{skin_name}+variables",
                type_id: Card::ScssID,
                content: File.read(
                  resource_path(theme_name, "_variables.scss")
                )
    update_card "#{skin_name}+style",
                type_id: Card::ScssID,
                content: File.read(
                  resource_path(theme_name, "_bootswatch.scss")
                )
    update_card "#{skin_name}+Image", type_id: Card::ImageID,
                mod: :bootstrap, storage_type: :coded,
                image: File.open(resource_path(theme_name, "thumbnail.png"))
  end
end
