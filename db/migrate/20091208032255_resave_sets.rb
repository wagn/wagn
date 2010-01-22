class ResaveSets < ActiveRecord::Migration
  def self.up
    #resave sets to generate correct pattern_spec_keys
    User.as :wagbot
    Card.search(:type=>'Set').each do |card|
      card.save!
    end
  end

  def self.down
  end
end
