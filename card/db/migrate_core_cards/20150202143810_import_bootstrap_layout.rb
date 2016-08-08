# -*- encoding : utf-8 -*-

class ImportBootstrapLayout < Card::CoreMigration
  def up
    layout = Card.fetch "Default Layout"
    if layout
      layout.name = "Classic Layout"
      layout.update_referers = true
      layout.save!
    end

    import_json "bootstrap_layout.json" # , pristine: true, output_file: nil
    if layout && layout.pristine? &&
       all = Card[:all]
      layout_rule_card = all.fetch trait: :layout
      style_rule_card  = all.fetch trait: :style
      if layout_rule_card.pristine? && style_rule_card.pristine?
        layout_rule_card.update_attributes! content: "[[Default Layout]]"
        if style_rule_card.item_names.first == "customized classic skin"
          Card.create! name: "customized bootstrap skin", type: "Skin",
                       content: "[[classic bootstrap skin]]\n[[*css]]"
          style_rule_card.update_attributes! content: "[[customized bootstrap skin]]"
        else
          style_rule_card.update_attributes! content: "[[classic bootstrap skin]]"
        end
      end
    end

    Card.create! name: "*header+*self+*read", content: "[[Anyone]]"

    # merge "style: functional" and "style: standard" into "style: cards"
    old_func = Card[:style_functional]
    old_func.name = "style: cards"
    old_func.codename = "style_cards"
    old_func.update_referers = true
    old_func.save!

    old_stand = Card[:style_standard]
    old_stand.codename = nil
    old_stand.delete!

    # these are hard-coded
    Card.create! name: "theme: bootstrap_default", type_code: :css, codename: "theme_bootstrap_default"
    Card.create! name: "style: bootstrap",         type_code: :css, codename: "bootstrap_css"
    Card.create! name: "style: bootstrap cards",   type_code: :css, codename: "bootstrap_cards"

    Card.create! name: "style: bootstrap compatible", type_code: :scss, codename: "style_bootstrap_compatible"
    Card.create! name: "script: bootstrap", type_code: :js, codename: "bootstrap_js"

    # add new setting: *default html view
    Card.create! name: "*default html view", type_code: :setting, codename: "default_html_view"
    Card.create! name: "*default html view+*right+*default", type_code: :phrase

    # retain old behavior (default view was content, now titled)
    Card.create! name: "*all+*default html view", content: "content"

    # update layouts to have explicit views in nests
    Card.search(type_id: Card::LayoutTypeID) do |lcard|
      lcontent = Card::Content.new lcard.content, lcard
      lcontent.find_chunks(Card::Content::Chunk::Include).each do |nest|
        nest.explicit_view = (nest.options[:inc_name] == "_main" ? "open" : "core")
      end
      lcard.update_attributes! content: lcontent.to_s
    end

    Card::Cache.reset_all
  end
end
