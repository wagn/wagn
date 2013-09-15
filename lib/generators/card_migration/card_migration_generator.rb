# -*- encoding : utf-8 -*-
require 'rails/generators/active_record'

class CardMigrationGenerator < ActiveRecord::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  def create_migration_file
    migration_template "card_migration.erb", "db/migrate_cards/#{file_name}.rb"
  end
end
