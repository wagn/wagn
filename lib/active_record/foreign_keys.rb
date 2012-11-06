
module ActiveRecord

  ### Foreign Key Schema Statements (postgresql only)
  module ConnectionAdapters
    module SchemaStatements
      def add_foreign_key(table_name, column_name, foreign_table_name, foreign_column_name = :id, on_cascade=nil)
        warn "add_foreign_key not implemented for #{self.class} connection"
      end

      def drop_foreign_key(table_name, column_name, foreign_table_name="")
        warn "drop_foreign_key not implemented for #{self.class} connection"
      end

      def add_unique_index(table_name, *column_names)
        warn "add_unique_index not implemented for #{self.class} connection"
      end

      def drop_unique_index(table_name, *column_names)
        warn "drop_unique_index not implemented for #{self.class} connection"
      end

      def add_constraint(table_name, name, type, constraint)
        warn "add_constraint not implemented for #{self.class} connection"
      end

      def drop_constraint(table_name, name, type, constraint="")
        warn "drop_constraint not implemented for #{self.class} connection"
      end

      def rename_table( name, new_name)
        warn "rename_table not implemented for #{self.class} connection"
      end

      def set_not_null
        warn "set_not_null not implemented for #{self.class} connection"
      end
    end

    class PostgreSQLAdapter
      def add_foreign_key(table_name, column_name, foreign_table_name, foreign_column_name = :id, on_cascade=nil)
        add_constraint(table_name, column_name, 'fkey',
          "FOREIGN KEY (#{column_name}) REFERENCES #{foreign_table_name} (#{foreign_column_name}) #{on_cascade}")
      end

      def drop_foreign_key(table_name, column_name, foreign_table_name="")
        drop_constraint(table_name, [table_name, column_name, 'fkey'].join('_'))
      end

      def add_unique_index(table_name, *column_names)
        add_constraint(table_name, column_names.join('_'), 'uniq',
          "UNIQUE (#{column_names.join(',')})")
      end

      def drop_unique_index(table_name, *column_names)
        drop_constraint(table_name, [table_name, column_names.join('_'), 'uniq'].join('_'))
      end

      def add_constraint(table_name, name, type, constraint)
        constraint_name = [table_name, name, type].join('_')
        execute "ALTER TABLE #{table_name} ADD CONSTRAINT #{constraint_name} #{constraint}"
      end

      def drop_constraint(table_name, constraint_name)
        execute "ALTER TABLE #{table_name} DROP CONSTRAINT #{constraint_name} "
      end

      def set_not_null(table_name, column_name)
        execute "Alter table #{table_name} alter column #{column_name} set not null"
      end

      def rename_table( name, new_name)
        execute "ALTER TABLE #{name} RENAME TO #{new_name}"
        # should check if it actually exists.  most of the time it will
        execute "ALTER TABLE #{name}_id_seq RENAME TO #{new_name}_id_seq"
      end
    end
  end
end
