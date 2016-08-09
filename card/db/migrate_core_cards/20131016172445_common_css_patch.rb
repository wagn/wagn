# -*- encoding : utf-8 -*-

class CommonCssPatch < Card::CoreMigration
  def up
    dir = File.join data_path, "1.12_stylesheets"
    card = Card["style: common"]
    if card && card.pristine?
      card.update_attributes! content: File.read("#{dir}/common.scss")
    end
  end
end
