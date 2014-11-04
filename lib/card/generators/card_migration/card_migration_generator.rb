# -*- encoding : utf-8 -*-
require 'rails/generators/active_record'

class CardMigrationGenerator < ActiveRecord::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  
  class_option 'core', :type => :boolean, aliases: '-c', :default => false, :group => :runtime, 
    desc: "Create card migration for wagn core"

  def create_migration_file
    root = options['core'] ? Wagn.gem_root : Wagn.root
    migration_template "card_migration.erb", "#{root}/db/migrate_cards/#{file_name}.rb"
  end
end
