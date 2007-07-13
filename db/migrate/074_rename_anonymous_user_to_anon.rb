class RenameAnonymousUserToAnon < ActiveRecord::Migration
  def self.up
    User.find_by_login('anonymous').update_attribute(:login,'anon')
  end

  def self.down
  end
end
