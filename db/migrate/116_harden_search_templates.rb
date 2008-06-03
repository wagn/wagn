class HardenSearchTemplates < ActiveRecord::Migration
  def self.up
    if User.as :admin
      Card.search(:type=>'Search',:right=>'*rform').each do |card|
        card.extension_type='HardTemplate'
        card.save!
      end
    end
  end

  def self.down
  end
end
