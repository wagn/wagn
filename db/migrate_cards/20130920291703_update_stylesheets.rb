# -*- encoding : utf-8 -*-

class UpdateStylesheets < Wagn::Migration
  def up
    dir = "#{Wagn.gem_root}/db/migrate_cards/data/1.12_stylesheets"
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
