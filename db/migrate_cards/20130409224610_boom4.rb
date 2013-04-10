# encoding: utf-8
load 'db/wagn_migration_helper.rb'

class Boom4 < ActiveRecord::Migration
  include WagnMigrationHelper
  def up
    contentedly do
      Card.create :name=>'boom4', :content=>Time.now().to_s
    end
  end

  def down
    contentedly do
      
    end
  end
end
