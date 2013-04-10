require 'rails/generators/active_record'

class ContentMigrationGenerator < ActiveRecord::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  #argument :card_list, :type => :string, :default => nil
  argument :attributes, :type => :array, :default => [], :banner => "field[:type][:index] field[:type][:index]"

  def create_migration_file
#        set_local_assigns!
    migration_template "content_migration.rb", "db/migrate_content/#{file_name}.rb"
  end

  protected
=begin
    attr_reader :migration_action
    
    def set_local_assigns!
      if file_name =~ /^(add|remove)_.*_(?:to|from)_(.*)/
        @migration_action = $1
        @table_name       = $2.pluralize
      end
    end
=end
end