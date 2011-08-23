class RequireEarlierMigrations < ActiveRecord::Migration
  def self.up
    fail "Your database is not ready to be migrated to Wagn version 1.7.0 or higher.\n"+
      "Please first install version 1.6.1 and run `rake db:migrate` before installing Wagn 1.7.0"
  end

  def self.down
    fail "Old migrations have been removed as of Wagn 1.7.0 because of incompatibility."
  end
end
