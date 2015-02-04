# -*- encoding : utf-8 -*-

class Card::CoreMigration < Card::Migration
  @type = :core_cards

  def import_json filename
    Cardio.config.action_mailer.perform_deliveries = false
    raw_json = File.read( data_path filename ) 
    json = JSON.parse raw_json
    Card.merge_list json["card"]["value"], :output_file=>File.join(data_path,"unmerged_#{ filename }")
    #fixme - output file should not be in gem!
  end
end
