FILL_FROM_VERSION=38
BOOTSTRAP_VERSION=109

# hoo boy this is all a big mess :-(
module ActiveRecord
  class Migrator
    def self.fill(from, to)
      sm_table = schema_migrations_table_name
      (from..to).each do |version|
        m = ActiveRecord::Base.connection.select_values("SELECT version FROM #{sm_table}").map(&:to_i).sort
        if !m.include?(version) 
          Base.connection.insert("INSERT INTO #{sm_table} (version) VALUES ('#{version}')") 
        end
      end
    end
      
    if Rails::VERSION::MAJOR >= 2 && Rails::VERSION::MINOR >= 1
      #cattr_accessor :migration_kluge
      #self.migration_kluge = []

      def migrated
        sm_table = self.class.schema_migrations_table_name
        #(self.migration_kluge + 
        m = Base.connection.select_values("SELECT version FROM #{sm_table}").map(&:to_i).sort
        if m.max && m.max >= BOOTSTRAP_VERSION       
          self.class.fill(FILL_FROM_VERSION,BOOTSTRAP_VERSION)
          m = m + (FILL_FROM_VERSION..BOOTSTRAP_VERSION).to_a
        end 
        m.sort
      end
    else
      alias_method :ar_set_schema_version, :set_schema_version
      def set_schema_version(version)
        self.send(:ar_set_schema_version, version.to_i == 1 ? BOOTSTRAP_VERSION : version )
      end
    end
  end
end
      
module SchemaVersionJumpHack
  # make rails happy that we defined this constant
end