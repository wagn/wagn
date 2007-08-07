class RemoveCompanyCardtype < ActiveRecord::Migration
  def self.up   
    if card = MCard.find_by_name("Company") and card.type=='Company'
      if MCard.find_all_by_type("Company").length < 1
        card.destroy
      end
    end
  end

  def self.down
  end
end
