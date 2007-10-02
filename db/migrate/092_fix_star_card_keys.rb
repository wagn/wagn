class FixStarCardKeys < ActiveRecord::Migration
  def self.up
    # THIS was breaking the migration.  do we need it?
   # Card.find_by_sql("select * from cards where name LIKE '%*%'").each do |c| c.update_attributes! :key=>c.name.to_key end  
  end

  def self.down
  end
end
