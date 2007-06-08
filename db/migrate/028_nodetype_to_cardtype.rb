class NodetypeToCardtype < ActiveRecord::Migration
  def self.up
    execute "alter table nodetypes rename to cardtypes"
    execute %{ update cards set type='Cardtype', extension_type='Cardtype' where type='Nodetype' }
     
  end

  def self.down
    execute "alter table cardtypes rename to nodetypes"
    execute %{ update cards set type='Nodetype', extension_type='Nodetype' where type='Cardtype' }
  end
end
