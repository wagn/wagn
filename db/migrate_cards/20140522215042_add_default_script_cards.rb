# -*- encoding : utf-8 -*-

class AddDefaultScriptCards < ActiveRecord::Migration
  include Wagn::MigrationHelper
  def up
    contentedly do
      card_type = { 'js' => :java_script, 'coffee' => :coffee_script}
      scripts        = %w{ jquery tinymce slot     card_menu jquery_helper html5shiv_printshiv  }
      types          = %w{ js     js      coffee   js        js            js                   }
        
      cardnames = scripts.map { |name| "script: #{name.gsub( '_', ' ' )}" }
      
      scripts.each_with_index do |name, index|
        Card.create! :name=>cardnames[index], :type=>card_type[types[index]], :codename=>"script_#{name}"
      end
      
      cardnames.pop # html5shiv_printshiv not in default list, only used for IE9 (handled in head.rb)
      Wagn::Cache.reset_global
      Card.create! :name=>"#{Card[:all].name}+*script", :content=>cardnames.map { |name| "[[#{ name }]]" }.join("\n")
    end
  end
end
