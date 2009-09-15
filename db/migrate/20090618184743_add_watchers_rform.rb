class AddWatchersRform < ActiveRecord::Migration
  def self.up
    User.as :wagbot
    unless Card["*watchers+*rform"]
      Card.create! :name => "*watchers+*rform", :type => "Pointer"
    end
  end

  def self.down
  end
end
