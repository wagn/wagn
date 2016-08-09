# -*- encoding : utf-8 -*-

class ConfigDescriptionsEtc < Card::CoreMigration
  def up
    raw_json = File.read(data_path "1.14_config_descriptions_etc.json")
    json = JSON.parse raw_json
    Card.merge_list json["card"]["value"], output_file: "tmp/unmerged_config_text.json"

    # fix missing +*from card
    c = Card.fetch "follower notification email", :from, new: {}
    c.content = Card[:wagn_bot].name
    c.save!
  end
end
