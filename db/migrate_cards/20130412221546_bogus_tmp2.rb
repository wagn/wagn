# encoding: utf-8
require 'wagn_migration_helper'

class BogusTmp2 < ActiveRecord::Migration
  include WagnMigrationHelper
  def up
    contentedly do
      fail "just a temporary migration to test deployment"
    end
  end

  def down
    contentedly do
      
    end
  end
end
