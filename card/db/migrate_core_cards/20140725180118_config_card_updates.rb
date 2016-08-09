# -*- encoding : utf-8 -*-

class ConfigCardUpdates < Card::CoreMigration
  def up
    raw_json = File.read(data_path "1.13_config_text.json")
    json = JSON.parse raw_json
    Card.merge_list json["card"]["value"], output_file: "tmp/unmerged_config_text.json"
  end
end
