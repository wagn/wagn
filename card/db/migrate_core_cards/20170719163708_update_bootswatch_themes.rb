# -*- encoding : utf-8 -*-

class UpdateBootswatchThemes < Card::Migration::Core
  THEMES = %w[Cerulean Cosmo Cyborg Darkly Flatly Journal Litera Lumen Lux
              Materia Minty Pulse Sandstone Simplex Slate Solar Spacelab
              Superhero United Yeti]
             .map(&:downcase).freeze

  def up
    THEMES.each do |theme_name|
      Skin.new(theme_name).create_or_update
    end
    Skin.new("Bootstrap default").update_scss file_name: "variables"
  end

  class Skin
    include ::Card::Model::SaveHelper

    def initialize theme_name
      @theme_name = theme_name
      @skin_name = "#{theme_name} skin"
      @skin_codename = @skin_name.downcase.tr(" ", "_")
    end

    def create_or_update
      Card.exists?(@skin_name) ? update_skin : create_skin
    end

    def create_skin
      Card.create! name: @skin_name,
                   codename: @skin_codename,
                   type_id: Card::SkinID,
                   content: "[[themeless bootstrap skin]]\n[[+bootswatch theme]]",
                   subcards: {
                     "+variables" => scss_args("variables"),
                     "+style" => scss_args("bootswatch"),
                     "+Image" => thumbnail_args
                   }
    end

    def update_skin
      update_scss file_name: "variables", field_name: "variables"
      update_scss file_name: "bootswatch", field_name: "style"
      update_tumbnail
    end

    def update_scss file_name:, field_name: file_name
      update_card "#{@skin_name}+#{field_name}", scss_args(file_name)
    end

    def update_tumbnail
      update_card "#{@skin_name}+Image", thumbnail_args
    end

    private

    def scss_args file_name
      {
        type_id: Card::ScssID,
        content: File.read(resource_path("_#{file_name}.scss"))
      }
    end

    def thumbnail_args
      {
        type_id: Card::ImageID,
        mod: :bootstrap, storage_type: :coded,
        image: File.open(resource_path("thumbnail.png"))
      }
    end

    def resource_path resource
      Card::Migration::Core.data_path "b4_themes/#{@theme_name.downcase.tr(" ","_")}/#{resource}"
    end
  end
end


