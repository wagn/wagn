class InitialPermissions < ActiveRecord::Migration
  def self.up
    @r = Role.find_by_codename('auth')
    @r.tasks = "edit_html,invite_users,rename_cards,edit_cards,set_datatypes,remove_cards,edit_cardtypes,edit_sealed_cards"
    @r.save
  end

  def self.down
  end
end
