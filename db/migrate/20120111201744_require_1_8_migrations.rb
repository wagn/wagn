class RequireEarlierMigrations < ActiveRecord::Migration
  def self.up
    fail %{
Your database is not ready to be migrated to #{Wagn::Version.full}.
Please first install version 1.8.0 and run `rake db:migrate`.

Sorry about this; we're working to prevent this problem in the future.
}
  end

  def self.down
    fail "Older migrations have been removed because of incompatibility."
  end
end
