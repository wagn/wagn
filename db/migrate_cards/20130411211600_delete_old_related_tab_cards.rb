# -*- encoding : utf-8 -*-

class DeleteOldRelatedTabCards < ActiveRecord::Migration
  include Wagn::MigrationHelper
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
