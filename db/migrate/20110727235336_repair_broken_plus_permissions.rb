class RepairBrokenPlusPermissions < ActiveRecord::Migration
  def self.up
    User.as :wagbot do
      Card.find_by_sql("select c1.* from cards c1 join cards c2 on c1.trunk_id = c2.id " +
        " where c1.read_rule_class='*all plus' and c2.read_rule_id <> c1.read_rule_id"
      ).each do |card|
        card.update_read_rule
      end
      Wagn::Cache.reset_global
    end
  end

  def self.down
  end
end
