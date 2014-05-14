# -*- encoding : utf-8 -*-

class AddScriptCards < ActiveRecord::Migration
  include Wagn::MigrationHelper
  def up
    contentedly do
      # TAKE "CSS" CODENAME FROM OLD *CSS CARD
      #old_css = Card[:css]
      #old_css.update_attributes :codename=>nil  #old *css card no longer needs this codename
      

      # CREATE CSS AND SCSS TYPES
      # following avoids name conflicts (create statements do not).  need better api to support this?
      # js_attributes = { :codename=>:js, :type_id=>Card::CardtypeID }
#       new_js = Card.fetch 'Javascript', :new=>js_attributes
#       new_js.update_attributes(js_attributes) unless new_js.new_card?
#       new_js.save!
#       
      #old_css.update_attributes :type_id=>new_js.id
      Card.create! :name=>'Javascript', :codename=>:javascript, :type_id=>Card::CardtypeID
      Card.create! :name=>'Coffeescript', :codename=>:coffeescript, :type_id=>Card::CardtypeID

   # skin_attributes = { :codename=>:skin, :type_id=>Card::CardtypeID }
   #    skin_card = Card.fetch 'Skin', :new=>skin_attributes
   #    skin_card.update_attributes( skin_attributes ) unless skin_card.new_card?
   #    skin_card.save!
      
      
      # PERMISSIONS FOR Javascript AND Coffeescript TYPES
      # ( the same as for CSS and SCSS)
      ['Javascript', 'Coffeescript'].each do |type|
        [ :create, :update, :delete].each do |action|
          Card.create! :name=>"#{type}+*type+#{Card[action].name}", :content=>"[[#{Card[:administrator].name}]]"
        end
      end
      
      Card.create! :name=>'*script', :codename=>:script, :type_id=>Card::SettingID
      script_set = "*script+#{Card[:right].name}"
      Card.create! :name=>"#{script_set}+#{Card[:default].name}", :type_id=>Card::PointerID
      Card.create! :name=>"#{script_set}+#{Card[:read].name}",    :content=>"[[#{Card[:anyone].name}]]"
      Card.create! :name=>"#{script_set}+#{Card[:options].name}", :content=>%({"type":"Javascript"}), :type=>Card::SearchTypeID  #TODO search for both: js and coffee
      Card.create! :name=>"#{script_set}+#{Card[:input].name}",   :content=>'select'
      Card.create! :name=>"#{script_set}+#{Card[:help].name}",    :content=>
        %{Javascript and Coffeescript for card's page. [[http://wagn.org/skins|more]]}  #TODO  help link?
      
      # IMPORT JAVASCRIPT  #TODO
        
      # example from style cards
      # simple_styles, classic_styles = [], []
      # %w{
      #   jquery-ui-smoothness.css functional.scss standard.scss right_sidebar.scss common.scss classic_cards.scss traditional.scss
      # }.each_with_index do |sheet, index|
      #   name, type = sheet.split '.'
      #   name.gsub! '_', ' '
      #   index < 5 ? simple_styles << name : classic_styles << name
      #   Card.create! :name=>"style: #{name}", :type=>type, :codename=>"style_#{name.to_name.key}"
      # end
            
      # CREATE SKINS
      
      # Card.create! :name=>"simple skin", :type=>'Skin', :content=>
#         simple_styles.map { |s| "[[style: #{s}]]" } * "\n"
#       Card.create! :name=>"classic skin", :type=>'Skin', :content=>
#         "[[simple skin]]\n" + ( classic_styles.map { |s| "[[style: #{s}]]" }.join"\n" )
#       
#       # CREATE DEFAULT STYLE RULE
#       # (this auto-generates cached file)
#       
#       default_skin = if old_css.content =~ /\S/
#         name = 'customized classic skin'
#         Card.create! :name=>name, :type=>'Skin', :content=>"[[classic skin]]\n[[*css]]"
#         name
#       else
#         old_css.delete!
#         'classic skin'
#       end
#       
#       Wagn::Cache.reset_global
#       begin
#         Card.create! :name=>"#{Card[:all].name}+*style", :content=>"[[#{default_skin}]]"
#       rescue
#         if default_skin =~ /customized/
#           Card["#{Card[:all].name}+*style"].update_attributes :content=>"[[classic skin]]"
#         end
#       end
      
    end
  end
end

