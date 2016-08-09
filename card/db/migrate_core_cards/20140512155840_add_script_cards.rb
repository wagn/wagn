# -*- encoding : utf-8 -*-

class Card
  def self.gimme! name, args={}
    Card::Auth.as_bot do
      c = Card.fetch(name, new: args)
      c.putty args
      Card.fetch name
    end
  end

  def putty args={}
    Card::Auth.as_bot do
      if args.present?
        update_attributes! args
      else
        save!
      end
    end
  end
end

class AddScriptCards < Card::CoreMigration
  def up
    # JavaScript and CoffeeScript types
    card = Card.fetch "CoffeeScript", new: {}
    card.codename = "coffee_script"
    card.type_id = Card::CardtypeID
    card.save!

    card = Card.fetch "JavaScript", new: {}
    card.codename = "java_script"
    card.type_id = Card::CardtypeID
    card.save!
    # Card.create! name: 'JavaScript', codename: :java_script, type_id: Card::CardtypeID
    # Card.create! name: 'CoffeeScript', codename: :coffee_script, type_id: Card::CardtypeID

    # Permissions for JavaScript and CoffeeScript types
    # ( the same as for CSS and SCSS)
    %w(JavaScript CoffeeScript).each do |type|
      [:create, :update, :delete].each do |action|
        Card.gimme!("#{type}+#{Card[:type].name}+#{Card[action].name}",
                    content: "[[#{Card[:administrator].name}]]")
      end
    end

    # +*script rules
    Card.create! name: "*script", codename: :script, type_id: Card::SettingID
    script_set = "*script+#{Card[:right].name}"
    Card.create! name: "#{script_set}+#{Card[:default].name}", type_id: Card::PointerID
    Card.create! name: "#{script_set}+#{Card[:read].name}",    content: "[[#{Card[:anyone].name}]]"
    Card.create! name: "#{script_set}+#{Card[:options].name}", content: %( {"type":["in", "JavaScript", "CoffeeScript"] }), type: Card::SearchTypeID
    Card.create! name: "#{script_set}+#{Card[:input].name}",   content: "list"
    Card.create! name: "#{script_set}+#{Card[:help].name}",    content:       %{ JavaScript (or CoffeeScript) for card's page. }  # TODO: help link?

    # Machine inputs and outputs
    default_rule_ending = "#{Card[:right].name}+#{Card[:default].name}"
    Card.create! name: "*machine output", codename: :machine_output
    Card.create! name: "*machine output+#{default_rule_ending}", type_id: Card::FileID
    Card.create! name: "*machine output+#{Card[:right].name}+#{Card[:read].name}", content: "_left"
    Card.create! name: "*machine input", codename: :machine_input
    Card.create! name: "*machine input+#{default_rule_ending}", type_id: Card::PointerID

    # create default script rule
    card_type = { "js" => "java_script", "coffee" => "coffee_script" }
    scripts        = %w(jquery tinymce slot     card_menu jquery_helper html5shiv_printshiv)
    types          = %w(js     js      coffee   js        js            js)
    # jquery.mobile  (in jquery_helper) must be after card to avoid mobileinit nastiness
    cardnames = scripts.map { |name| "script: #{name.tr('_', ' ')}" }

    scripts.each_with_index do |name, index|
      Card.create! name: cardnames[index], type: card_type[types[index]], codename: "script_#{name}"
    end

    cardnames.pop # html5shiv_printshiv not in default list, only used for IE9 (handled in head.rb)
    Card::Cache.reset_all
    Card.create! name: "#{Card[:all].name}+*script", content: cardnames.map { |name| "[[#{name}]]" }.join("\n")
  end
end
