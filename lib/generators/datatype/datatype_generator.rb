class DatatypeGenerator < Rails::Generator::NamedBase

  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions class_path, "#{class_name}Datatype", "#{class_name}DatatypeTest"

      # Model, test, and fixture directories.
      m.directory File.join('app/datatypes', class_path)
      m.directory File.join('test/unit/datatypes', class_path)

      # Model class, unit test, and fixtures.
      m.template 'model.rb.template',      File.join('app/datatypes', class_path, "#{file_name}_datatype.rb")
      m.template 'unit_test.rb.template',  File.join('test/unit/datatypes', class_path, "#{file_name}_datatype_test.rb")
    end
  end
  
  def datatype_name
    class_name.gsub(/([A-Z][a-z])/, ' \1').strip
  end

end
