class AddToggleAndPhrase < ActiveRecord::Migration
  def self.up
    if User.as :admin
      Card::Cardtype.create(:name=>'Toggle')
      Card::Cardtype.create(:name=>'Phrase')
    end
  end

  def self.down
  end
end
