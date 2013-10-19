# -*- encoding : utf-8 -*-

class CommonCssPatch < ActiveRecord::Migration
  include Wagn::MigrationHelper
  def up
    contentedly do
      dir = "#{Rails.root}/db/migrate_cards/data/1.12_stylesheets"
      card = Card["style: common"]
      if card && card.pristine?
        card.update_attributes! :content=>File.read("#{dir}/common.scss")
      end
      Card::Set::Right::Style.delete_style_files
    end
  end

  def down
    contentedly do
      
    end
  end
end
