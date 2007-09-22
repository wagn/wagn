class PermissionPartyNotNull < ActiveRecord::Migration
  def self.up
    execute %{delete from permissions where party_id is null}
    execute %{delete from permissions where card_id is null}
    set_not_null 'permissions', 'party_id'  
    set_not_null 'permissions', 'card_id'   
    set_not_null 'permissions', 'party_type'
    #add_foreign_key('permissions', 'card_id', 'cards')
  end

  def self.down
  end
end
