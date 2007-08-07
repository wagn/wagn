class CardtypeGenerator < Rails::Generator::NamedBase

  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions class_path, "Card::#{class_name}"

      # Model, test, and fixture directories.
      m.directory File.join('app/cardtypes', class_path)
      m.directory File.join('spec/models/cardtypes', class_path)
      m.directory File.join('db/migrate', class_path)

      # Model class, unit test, and fixtures.
      
      # FIXME - check for name collisions
      #raise "Another migration is already named #{migration_file_name}: #{existing_migrations(migration_file_name).first}" if migration_exists?(migration_file_name)
      
      m.template 'model.rb.template',      File.join('app/cardtypes', class_path, "#{file_name}.rb")
      m.template 'model_spec.rb.template',  File.join('spec/models/cardtypes', class_path, "#{file_name}_spec.rb")
      m.migration_template 'migration.rb.template',  'db/migrate', :migration_file_name=>"add_#{file_name}_cardtype"

    end
  end
  
  def datatype_name
    class_name.gsub(/([A-Z][a-z])/, ' \1').strip
  end

end
