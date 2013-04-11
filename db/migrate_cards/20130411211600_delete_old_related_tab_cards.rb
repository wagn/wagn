# encoding: utf-8
require 'wagn_migration_helper'

class DeleteOldRelatedTabCards < ActiveRecord::Migration
  include WagnMigrationHelper
  def up
    contentedly do
      [
        '*related',
        '*incoming',
        '*outgoing',
        '*community',
        '*plusses',
        'watcher instructions for related tab'
      ].each do |name|
        c = Card[name]
        c.codename = nil
        c.delete!
      end      
    end
  end

  def down
    contentedly do
      
    end
  end
end
