require_dependency 'db/card_creator.rb'

class JumpToVersion109 < ActiveRecord::Migration
  def self.up
    Rake::Task['db:schema:load'].invoke
    Rake::Task['wagn:bootstrap:load'].invoke
    Rake::Task['db:migrate'].invoke
    ActiveRecord::Base.connection.commit_db_transaction
    exit 0
  end
  
  def self.down
    raise IrreversibleMigration
  end
      
end
