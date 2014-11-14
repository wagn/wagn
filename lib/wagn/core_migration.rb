# -*- encoding : utf-8 -*-

class Wagn::CoreMigration < Wagn::Migration
  def migration_paths
    Wagn::Migration.core_card_migration_paths
  end
  
  def schema_mode
    Wagn::Migration.schema_mode :card
  end
  
  def import_json filename
    Wagn.config.action_mailer.perform_deliveries = false
    raw_json = File.read( data_path filename ) 
    json = JSON.parse raw_json
    Card.merge_list json["card"]["value"], :output_file=>File.join(data_path,"unmerged_#{ filename }")
  end
end
