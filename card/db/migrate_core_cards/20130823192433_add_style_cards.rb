# -*- encoding : utf-8 -*-

class AddStyleCards < Card::CoreMigration
  def up
    # TAKE "CSS" CODENAME FROM OLD *CSS CARD
    old_css = Card[:css]
    old_css.update_attributes codename: nil
    # old *css card no longer needs this codename

    # CREATE CSS AND SCSS TYPES
    # following avoids name conflicts (create statements do not).
    # need better api to support this?
    css_attributes = { codename: :css, type_id: Card::CardtypeID }
    new_css = Card.fetch "CSS", new: css_attributes
    new_css.update_attributes(css_attributes) unless new_css.new_card?
    new_css.save!

    old_css.update_attributes type_id: new_css.id

    Card.create! name: "SCSS", codename: :scss, type_id: Card::CardtypeID

    skin_attributes = { codename: :skin, type_id: Card::CardtypeID }
    skin_card = Card.fetch "Skin", new: skin_attributes
    skin_card.update_attributes(skin_attributes) unless skin_card.new_card?
    skin_card.save!

    # PERMISSIONS FOR CSS AND SCSS TYPES

    %w(CSS SCSS Skin).each do |type|
      [:create, :update, :delete].each do |action|
        Card.create! name: "#{type}+#{Card[:type].name}+#{Card[action].name}",
                     content: "[[#{Card[:administrator].name}]]"
      end
    end

    Card.create! name: "*style",
                 codename: :style,
                 type_id: Card::SettingID
    style_set = "*style+#{Card[:right].name}"
    Card.create! name: "#{style_set}+#{Card[:default].name}",
                 type_id: Card::PointerID
    Card.create! name: "#{style_set}+#{Card[:read].name}",
                 content: "[[#{Card[:anyone].name}]]"
    Card.create! name: "#{style_set}+#{Card[:options].name}",
                 content: %({"type":"Skin"}), type: Card::SearchTypeID
    Card.create! name: "#{style_set}+#{Card[:input].name}",
                 content: "select"
    Card.create! name: "#{style_set}+#{Card[:help].name}",
                 content: "Skin (collection of stylesheets) for card's page." \
                          "[[http://wagn.org/skins|more]]"

    # IMPORT STYLESHEETS

    simple_styles = []
    classic_styles = []
    %w(
      jquery-ui-smoothness.css functional.scss standard.scss right_sidebar.scss
      common.scss classic_cards.scss traditional.scss
    ).each_with_index do |sheet, index|
      name, type = sheet.split "."
      name.tr! "_", " "
      index < 5 ? simple_styles << name : classic_styles << name
      Card.create! name: "style: #{name}", type: type,
                   codename: "style_#{name.to_name.key}"
    end

    # CREATE SKINS

    Card.create! name: "simple skin", type: "Skin",
                 content: simple_styles.map { |s| "[[style: #{s}]]" } * "\n"
    classic_items = classic_styles.map { |s| "[[style: #{s}]]" }.join "\n"
    Card.create! name: "classic skin", type: "Skin",
                 content: "[[simple skin]]\n#{classic_items}"

    # CREATE DEFAULT STYLE RULE
    # (this auto-generates cached file)

    default_skin =
      if old_css.content =~ /\S/
        name = "customized classic skin"
        Card.create! name: name, type: "Skin",
                     content: "[[classic skin]]\n[[*css]]"
        name
      else
        old_css.delete!
        "classic skin"
      end

    Card::Cache.reset_all
    begin
      Card.create! name: "#{Card[:all].name}+*style",
                   content: "[[#{default_skin}]]"
    rescue
      if default_skin =~ /customized/
        all_style = Card["#{Card[:all].name}+*style"]
        all_style.update_attributes content: "[[classic skin]]"
      end
    end
  end
end
