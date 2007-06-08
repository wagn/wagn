class SimplifyCardtypes < ActiveRecord::Migration
  def self.up
    execute %{ update cards set type='Basic' where type='Connection' }
  end

  def self.down
  end
end
