class FixWeirdAnyoneKeys < ActiveRecord::Migration
  def self.up 
    Card::Role.reset_column_information
    Card.reset_column_information 
    User.as :admin
    ['Anyone', 'Anyone Signed In'].each do |name|
      c = Card.find_by_name_and_trash(name, false)
      if c
        c.key = c.name.to_key 
        puts "Set #{name} to #{c.key}"
        c.save!   
      else
        puts "Failed to update '#{name}'"
      end
    end
  end

  def self.down
  end
end
