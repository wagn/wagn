# -*- encoding : utf-8 -*-

class AddStyleCards < ActiveRecord::Migration
  include Wagn::MigrationHelper
  def up
    contentedly do
      old_css = Card[:css]
      old_css.update_attributes :codename=>nil
      
      new_css = Card.create :name=>'CSS', :codename=>:css, :type_id=>Card::CardtypeID  # FIXME: high danger of name conflict
      old_css.update_attributes :type_id=>new_css.id
      
      
      
      # set permissions on these cards
      
      Card.create :name=>'*style', :codename=>:style,      :type_id=>Card::SettingID
      Card.create :name=>'*style+*right+*default',         :type_id=>Card::PointerID
      Card.create :name=>'*all+*style', :content=>"[[classic style]]\n[[*css]]"
    end
  end

  def down
    contentedly do
      
    end
  end
end
