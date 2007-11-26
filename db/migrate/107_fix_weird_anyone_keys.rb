class FixWeirdAnyoneKeys < ActiveRecord::Migration
  def self.up
    ['Anyone', 'Anyone Signed In'].each do |name|
      c = Card.find_by_name_and_trash(name, false)
      if c
        c.key = c.name.to_key
        c.save!
      end
    end
  end

  def self.down
  end
end
