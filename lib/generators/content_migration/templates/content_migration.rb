# encoding: utf-8
load 'db/wagn_migration_helper.rb'

class <%= migration_class_name %> < ActiveRecord::Migration<%# %>
  include WagnMigrationHelper
  def up
    contentedly do
      
    end
  end

  def down
    contentedly do
      
    end
  end
end
