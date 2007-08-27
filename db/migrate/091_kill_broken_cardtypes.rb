class KillBrokenCardtypes < ActiveRecord::Migration
  def self.up
    ghost_types = Cardtype.find_by_sql(%{select id from cardtypes ct2 where not exists 
      (select * from cards where extension_type='Cardtype' and extension_id=ct2.id)})
    if ghost_types.length > 0  
      execute %{delete from cardtypes where id in (#{ghost_types.plot(:id).join(',')})}
    end
  end

  def self.down
  end
end
