# -*- encoding : utf-8 -*-

class BootstrapThemes < Card::CoreMigration
  def up
    Card.create! name: "themeless bootstrap skin", type_code: :skin, content: "[[style: bootstrap]]\n[[style: jquery-ui-smoothness]]\n[[style: cards]]\n[[style: right sidebar]]\n[[style: bootstrap cards]]"
    %w(cerulean cosmo cyborg darkly flatly journal lumen paper readable sandstone simplex slate spacelab superhero united yeti).each do |theme|
      Card.create! name: "theme: #{theme}", type_code: :css, codename: "theme_#{theme}"
      Card.create! name: "#{theme} skin", type_code: :skin, codename: "#{theme}_skin", content: "[[themeless bootstrap skin]]\n[[theme: #{theme}]]"
    end

    if credit_card = Card["*credit"]
      credit_card.codename = "credit"
      credit_card.save!
    end

    style_right = Card[:style].fetch trait: :right, new: {}

    style_right_options = style_right.fetch trait: :options, new: {}
    style_right_options.content = %({"type":"Skin","sort":"name"})
    style_right_options.save!

    style_right_input = style_right.fetch trait: :input, new: {}
    style_right_input.content = "radio"
    style_right_input.save!

    style_right_option_label = style_right.fetch trait: :options_label, new: {}
    style_right_option_label.content = "Image"
    style_right_option_label.save!

    import_json "skin_images.json"

    if sidebar_card = Card["*sidebar"]
      new_content = sidebar_card.content.gsub(/(\*(logo|credit))\|content/, '\1|content_panel')
      sidebar_card.update_attributes! content: new_content
    end
  end
end
