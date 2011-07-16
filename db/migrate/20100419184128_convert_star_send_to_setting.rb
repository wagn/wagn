class ConvertStarSendToSetting < ActiveRecord::Migration
  def self.up
    User.as :wagbot
    c = Card.fetch_or_create "*send", :type=>"Setting"
    if c and c.type!="Setting"
      c.type = "Setting"
      c.save!
    end
    Card.search(:right=>'*type').each do |c|
      if c.type != 'Set'
        c.type='Set'
        c.save!
      end
    end
    c = Card['*right+*right']
    if c and c.type!="Set"
      c.type = "Set"
      c.save!
    end

  end

  def self.down
  end
end
