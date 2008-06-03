class AddHtmlCardtype < ActiveRecord::Migration
  def self.up
    if User.as :admin
      Card::Cardtype.create(:name=>'HTML')
    end
  end

  def self.down
  end
end
