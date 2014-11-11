# -*- encoding : utf-8 -*-

class ConfigCardUpdates < Wagn::Migration
  def up
    raw_json = File.read( File.join Wagn.gem_root, 'db/migrate_cards/data/1.13_config_text.json' )
    json = JSON.parse raw_json
    Card.merge_list json["card"]["value"], :output_file=>"tmp/unmerged_config_text.json", :pristine=>true
  end
end
