# -*- encoding : utf-8 -*-

class BootswatchThemes < Card::CoreMigration
  def up
    themeless = Card.fetch "themeless bootstrap skin", new: { type_code: :skin }
    themeless.update_attributes! content: "[[style: jquery-ui-smoothness]]\n[[style: cards]]\n[[style: right sidebar]]\n[[style: bootstrap cards]]"
    bs = Card[:bootstrap_css]
    bs.update_attributes! codename: nil
    bs.delete!

    Card.create! name: "bootswatch shared", type_code: :scss, codename: "bootswatch_shared"
    Card.create! name: "bootswatch theme+*right+*structure", type_id: Card::ScssID, content: "{{_left+variables}}{{bootswatch shared}}{{_left+style}}"
    %w(bootstrap_default cerulean cosmo cyborg darkly flatly journal lumen paper readable sandstone simplex slate spacelab superhero united yeti).each do |theme_name|
      path = data_path "themes/#{theme_name}"
      theme = Card.fetch "#{theme_name} skin"
      if theme
        theme.update_attributes! type_id: Card::SkinID, content: "[[themeless bootstrap skin]]\n[[+bootswatch theme]]", subcards: {
          "+variables" => { type_id: Card::ScssID, content: File.read(File.join path, "_variables.scss") },
          "+style"     => { type_id: Card::ScssID, content: File.read(File.join path, "_bootswatch.scss") }
        }
      else
        Card.create! name: "#{theme_name.sub('_', ' ')} skin", type_id: Card::SkinID, content: "[[themeless bootstrap skin]]\n[[+bootswatch theme]]", subcards: {
          "+variables" => { type_id: Card::ScssID, content: File.read(File.join path, "_variables.scss") },
          "+style"     => { type_id: Card::ScssID, content: File.read(File.join path, "_bootswatch.scss") }
        }
      end
    end
  end
end
