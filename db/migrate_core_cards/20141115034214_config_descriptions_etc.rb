# -*- encoding : utf-8 -*-

class ConfigDescriptionsEtc < Wagn::Migration
  def up
    raw_json = File.read( data_path '1.14_config_descriptions_etc.json' )
    json = JSON.parse raw_json
    Card.merge_list json["card"]["value"], :output_file=>"tmp/unmerged_config_text.json"
    
    # fix missing +*from card
    Card.create! :name=>"follower notification email+#{Card[:from].name}", :content=>Card[:wagn_bot].name
  end
end
