# -*- encoding : utf-8 -*-

class UpdateStylesheets < ActiveRecord::Migration
  include Wagn::MigrationHelper
  def up
    contentedly do
      dir = "#{Rails.root}/db/migrate_cards/data/1.12_stylesheets"
      %w{ common traditional }.each do |sheetname|
        card = Card["style: #{sheetname}"]
        if card && card.pristine?
          card.update_attributes! :content=>File.read("#{dir}/#{sheetname}.scss")
        end
      end
      
      if c = Card['*all+*style+file']
        c.delete!
      end
    end
  end

  def down
    contentedly do
      
    end
  end
end
