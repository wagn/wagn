# -*- encoding : utf-8 -*-

class Wagn::CoreMigration < Wagn::Migration
  def data_path filename=nil
    if filename
      migration_paths.each do |path|
        data_path = File.join path, filename
        return data_path if File.exists? data_path
      end
    else
      migration_paths.first
    end
  end
  
  def migration_paths
    Wagn::Migration.core_card_migration_paths
  end
  
  def schema_mode
    Wagn::Migration.schema_mode :card
  end
  
  def import_json filename, root=Wagn::Migration.deck_card_migration_paths.first
    Wagn.config.action_mailer.perform_deliveries = false
    raw_json = File.read( data_path filename ) 
    json = JSON.parse raw_json
    Card.merge_list json["card"]["value"], :output_file=>File.join(data_path,"unmerged_#{ filename }")
  end
  
  def import_json_to_core filename
    import_json filename, Wagn::Migration.card_migration_paths.first
  end

end
