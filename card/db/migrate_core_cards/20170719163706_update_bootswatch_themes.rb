# -*- encoding : utf-8 -*-

class UpdateBootswatchThemes < Card::Migration::Core
  def up
    #%w(bootstrap_default cerulean cosmo cyborg darkly flatly journal lumen paper readable sandstone simplex slate spacelab superhero
    %w[united yeti].each do |theme_name|
      path = data_path "b4_themes/#{theme_name}"
      update_card "#{theme_name} skin+variables", content: "" #File.read(File.join(path, "_variables.scss")), type_id: Card::ScssID
      update_card "#{theme_name} skin+style", content: File.read(File.join(path, "_bootswatch.scss")), type_id: Card::CssID
    end
  end
end
