# -*- encoding : utf-8 -*-

class AddStyleCards < ActiveRecord::Migration
  include Wagn::MigrationHelper
  def up
    contentedly do
      old_css = Card[:css]
      old_css.update_attributes :codename=>nil  #old *css card no longer needs this codename
      
      # following avoids name conflicts (create statements do not).  need better api to support this?
      css_attributes = { :codename=>:css, :type_id=>Card::CardtypeID }
      new_css = Card.fetch 'CSS', :new=>css_attributes
      new_css.update_attributes(css_attributes) unless new_css.new_card?
      new_css.save!
      
      old_css.update_attributes :type_id=>new_css.id
      
      Card.create! :name=>'SCSS', :codename=>:scss, :type_id=>Card::CardtypeID
      
      # FIXME! set permissions on CSS and SCSS cards!
      
      Card.create! :name=>'*style', :codename=>:style,      :type_id=>Card::SettingID
      Card.create! :name=>'*style+*right+*default',         :type_id=>Card::PointerID
      Card.create! :name=>'*all+*style', :content=>"[[style: classic]]\n[[*css]]"
      
      classic_styles = []
      %w{ jquery-ui-smoothness.css functional.scss }.each do |sheet|
        name, type = sheet.split '.'
        classic_styles << name
        
        Card.create! :name=>"style: #{name}", :type=>type, :codename=>"style_#{name.to_name.key}"
      end
      
      
      %w{ minimal.scss settings.scss page.scss defaults.css card.css home.scss }.each do |sheet|
        name, type = sheet.split '.'
        classic_styles << name
        
        content = File.read "#{Rails.root}/app/assets/stylesheets/#{sheet}"
        Card.create! :name=>"style: #{name}", :type=>type, :content=>content
      end
      
      classic_content = classic_styles.map { |s| "[[style: #{s}]]" }.join"\n"
      Card.create! :name=>"style: classic", :type=>'Pointer', :content=> classic_content
    end
  end

  def down
    contentedly do
      
    end
  end
end
