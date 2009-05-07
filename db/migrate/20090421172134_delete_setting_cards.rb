class DeleteSettingCards < ActiveRecord::Migration
  def self.up
    User.as :wagbot
    if setting_card = Card['Setting'] and setting_card.type=='Cardtype'
      Card::Setting.find(:all).each do |card|
        card.extension = nil
        card.save
        card.destroy
      end
      setting_card.destroy
    end
  end

  def self.down
  end
end
