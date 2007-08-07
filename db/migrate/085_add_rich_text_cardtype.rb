require_dependency 'db/migration_helper'

class AddRichTextCardtype < ActiveRecord::Migration
	include MigrationHelper

  def self.up 
  	add_cardtype "RichText"
  end

  def self.down
  end
end
