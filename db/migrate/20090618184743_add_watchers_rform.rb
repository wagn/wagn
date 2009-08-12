class AddWatchersRform < ActiveRecord::Migration
  def self.up
    User.as :wagbot
    Card.create! :name => "*watchers+*rform", :type => "Pointer"
  end

  def self.down
  end
end
