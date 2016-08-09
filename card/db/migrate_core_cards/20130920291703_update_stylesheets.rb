# -*- encoding : utf-8 -*-

class UpdateStylesheets < Card::CoreMigration
  def up
    dir = File.join data_path, "1.12_stylesheets"
    %w(common traditional).each do |sheetname|
      card = Card["style: #{sheetname}"]
      if card && card.pristine?
        card.update_attributes! content: File.read("#{dir}/#{sheetname}.scss")
      end
    end

    if (c = Card["*all+*style+file"])
      c.delete!
    end
  end
end
