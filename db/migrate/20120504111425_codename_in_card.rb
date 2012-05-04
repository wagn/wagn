class CodenameInCard < ActiveRecord::Migration
  def up
    Card::Codename.all.each do |r|
      Card.where(:id=>r.card_id).update_all(:codename=>r.codename)
    end
  end

  def down
  end
end
