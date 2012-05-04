class CodenameInCard < ActiveRecord::Migration
  def up
    Card::Codename.all do |r|
      Card.where(:id=>r.card_id).update(:codename=>r.codename)
    end
  end

  def down
  end
end
