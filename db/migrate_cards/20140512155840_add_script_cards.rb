# -*- encoding : utf-8 -*-

class AddScriptCards < ActiveRecord::Migration
  include Wagn::MigrationHelper
  def up
    contentedly do    
      # JavaScript and CoffeeScript types

      Card.create! :name=>'JavaScript', :codename=>:java_script, :type_id=>Card::CardtypeID
      Card.create! :name=>'CoffeeScript', :codename=>:coffee_script, :type_id=>Card::CardtypeID
      
      # Permissions for JavaScript and CoffeeScript types
      # ( the same as for CSS and SCSS)
      ['JavaScript', 'CoffeeScript'].each do |type|
        [ :create, :update, :delete].each do |action|
          Card.create! :name=>"#{type}+#{Card[:type].name}+#{Card[action].name}", 
            :content=>"[[#{Card[:administrator].name}]]"
        end
      end
      
      # +*script rules
      Card.create! :name=>'*script', :codename=>:script, :type_id=>Card::SettingID
      script_set = "*script+#{Card[:right].name}"
      Card.create! :name=>"#{script_set}+#{Card[:default].name}", :type_id=>Card::PointerID
      Card.create! :name=>"#{script_set}+#{Card[:read].name}",    :content=>"[[#{Card[:anyone].name}]]"
      Card.create! :name=>"#{script_set}+#{Card[:options].name}", :content=>%( {"type":["in", "JavaScript", "CoffeeScript"] }), :type=>Card::SearchTypeID  
      Card.create! :name=>"#{script_set}+#{Card[:input].name}",   :content=>'select'
      Card.create! :name=>"#{script_set}+#{Card[:help].name}",    :content=>
        %{ JavaScript (or CoffeeScript) for card's page. }  #TODO  help link?
      
      # IMPORT JAVASCRIPT  #TODO
     
      # Machine inputs and outputs
      default_rule_ending = "#{ Card[:right].name }+#{ Card[ :default ].name }"
      Card.create! :name=>'*machine output', :codename=>:machine_output
      Card.create! :name=>"*machine output+#{default_rule_ending}", :type_id=>Card::FileID
      Card.create! :name=>'*machine input', :codename=>:machine_input
      Card.create! :name=>"*machine input+#{default_rule_ending}", :type_id=>Card::PointerID
    end
  end
end

