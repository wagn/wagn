# -*- encoding : utf-8 -*-

class FixSkinImages < Card::CoreMigration
  def up
    # This is needed because the bootswatch_themes migration removed codenames.
    # They were no longer needed for style handling but are still needed for images
    %w(bootstrap_default cerulean cosmo cyborg darkly flatly journal lumen paper readable sandstone simplex slate spacelab superhero united yeti).each do |theme_name|
      theme_name = "#{theme_name}_skin"
      Card.fetch(theme_name).update_attributes! codename: theme_name
    end
  end
end
