class FixTrashedLeftCards < ActiveRecord::Migration
  def self.up
    User.as :wagbot do
      ActiveRecord::Base.connection.select_all(
        "select name from cards where trash is true and id in (select trunk_id from cards where trash is false)"
      ).each do |record|
        begin
          Card.create :name=>record["name"]
        rescue
          puts "migration failed for #{record["name"]}"
        end
      end
    end
  end

  def self.down
  end
end
