class CardMigrationGenerator < Rails::Generator::NamedBase
  attr_accessor :migration_name
  
  def manifest
    record do |m|           
      puts "CARD_NAME: #{card.name}"
      puts "CONTENT:\n#{card.content}\n"      
              
      
      @migration_name = "set_#{sanitized_name}"
      n = 2
      while migration_exists?(@migration_name)
        @migration_name = "set_#{sanitized_name}_#{n}"
        n += 1
      end
      
      puts "MIGRATION_NAME: #{migration_name}"
      
      # ensure migration dir
      m.directory File.join('db/migrate', class_path)
      m.migration_template 'migration.rb.template',  'db/migrate', :migration_file_name=>migration_name
    end
  end
  
  def sanitized_name
    file_name.to_cardname.to_key.gsub(/\*/,'star_').gsub(/\+/,'_plus_') 
  end
  
  def card
    User.as(:wagbot)
    @card||=Card[file_name]
  end
  
  # borrowed this code from rails generator commands-- couldn't figure out how to invoke it from here   
  def migration_exists?(file_name)
    not existing_migrations(file_name).empty?
  end      
  
  def existing_migrations(file_name)
    Dir.glob("#{migration_directory}/[0-9]*_*.rb").grep(/[0-9]+_#{file_name}.rb$/)
  end
  
  def migration_directory 
    "#{RAILS_ROOT}/db/migrate"
  end
end
