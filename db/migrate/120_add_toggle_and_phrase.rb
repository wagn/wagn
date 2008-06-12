class AddToggleAndPhrase < ActiveRecord::Migration
  def self.up     
    Card::Base.reset_column_information
    Card::Basic.reset_column_information
    Card::Cardtype.reset_column_information
    if User.as :admin
      Card::Cardtype.create(:name=>'Toggle')
      Card::Cardtype.create(:name=>'Phrase')
    end
  end

  def self.down
  end
end
