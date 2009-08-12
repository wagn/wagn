class AddMissingWatchers < ActiveRecord::Migration
  def self.up
    User.as :wagbot
    unless Card["*watchers"]
      watchers = Card.create! :name=>"*watchers"
      wf = Card["*watchers+*rform"]
      wf.trunk_id = watchers.id
      wf.save!
    end
  end

  def self.down
  end
end
