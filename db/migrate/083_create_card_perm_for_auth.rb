class CreateCardPermForAuth < ActiveRecord::Migration
  def self.up
    @r = Role.find_by_codename('auth')
    @r.tasks << ",create_cards"
    @r.save
  end

  def self.down
  end
end
