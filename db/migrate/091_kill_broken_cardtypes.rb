class KillBrokenCardtypes < ActiveRecord::Migration
  def self.up
    execute %{delete from cardtypes where id in 
      (select id from cardtypes where not exists 
        (select * from cards where extension_type='Cardtype' and extension_id=cardtypes.id))
    }
  end

  def self.down
  end
end
