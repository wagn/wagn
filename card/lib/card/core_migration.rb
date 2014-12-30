# -*- encoding : utf-8 -*-

class Card::CoreMigration < Card::Migration
  def migration_paths
    Card::Migration.paths :core_cards
  end
  
  def schema_mode
    Card::Migration.schema_mode :core_cards
  end
  
  def import_json filename
    CardRailtie.config.perform_deliveries = false
    raw_json = File.read( data_path filename ) 
    json = JSON.parse raw_json
    Card.merge_list json["card"]["value"], :output_file=>File.join(data_path,"unmerged_#{ filename }")
    #fixme - output file should not be in gem!
  end
end
