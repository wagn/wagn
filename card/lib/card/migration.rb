# -*- encoding : utf-8 -*-
 
class Card::Migration < ActiveRecord::Migration
  @type = :deck_cards

  class << self

    # Rake tasks use class methods, migrations use instance methods.
    # To avoid repetition a lot of instance methods here just call class methods.
    # The subclass Card::CoreMigration needs a different @type so we can't use a
    # class variable @@type. It has to be a class instance variable.
    # Migrations are subclasses of Card::Migration or Card::CoreMigration but they
    # don't inherit the @type. The method below solves this problem.
    def type
      @type || (ancestors[1] && ancestors[1].type)
    end

    def find_unused_name base_name
      test_name = base_name
      add = 1
      while Card.exists?(test_name) do
        test_name = "#{base_name}#{add}"
        add +=1
      end
      test_name
    end

    def migration_paths mig_type=type
      Cardio.migration_paths mig_type
    end

    def schema mig_type=type
      Cardio.schema mig_type
    end

    def schema_suffix mig_type=type
      Cardio.schema_suffix mig_type
    end

    def schema_mode mig_type=type
      new_suffix = schema_suffix mig_type
      original_suffix = ActiveRecord::Base.table_name_suffix

      ActiveRecord::Base.table_name_suffix = new_suffix
      yield
      ActiveRecord::Base.table_name_suffix = original_suffix
    end

    def assume_migrated_upto_version
      schema_mode do
        ActiveRecord::Schema.assume_migrated_upto_version schema, migration_paths
      end
    end
    
    def data_path filename=nil
      path = migration_paths.first
      File.join( [ migration_paths.first, 'data', filename ].compact )
    end
    
  end

  def contentedly &block
    Card::Cache.reset_global
    Cardio.schema_mode '' do
      Card::Auth.as_bot do
        ActiveRecord::Base.transaction do
          begin
            yield
          ensure
            Card::Cache.reset_global
          end
        end
      end
    end
  end

  def import_json filename, merge_opts={}
    Card.config.action_mailer.perform_deliveries = false
    merge_opts.reverse_merge! :output_file=>File.join(data_path,"unmerged_#{ filename }")
    Card.merge_list read_json(filename), merge_opts
  end
  
  def read_json filename
    raw_json = File.read( data_path filename )
    json = JSON.parse raw_json
    json["card"]["value"]
  end

  def data_path filename=nil
    self.class.data_path filename
  end

  def schema_mode
    Cardio.schema_mode self.class.type
  end

  def migration_paths
    Cardio.paths self.class.type
  end


  # Execute this migration in the named direction
  # copied from ActiveRecord to wrap "up" in "contentendly"
  def migrate(direction)
    return unless respond_to?(direction)

    case direction
    when :up   then announce "migrating"
    when :down then announce "reverting"
    end

    time   = nil
    ActiveRecord::Base.connection_pool.with_connection do |conn|
      @connection = conn
      if respond_to?(:change)
        if direction == :down
          recorder = CommandRecorder.new(@connection)
          suppress_messages do
            @connection = recorder
            change
          end
          @connection = conn
          time = Benchmark.measure {
            self.revert {
              recorder.inverse.each do |cmd, args|
                send(cmd, *args)
              end
            }
          }
        else
          time = Benchmark.measure { change }
        end
      else
        time = Benchmark.measure { contentedly { send(direction) } }
      end
      @connection = nil
    end

    case direction
    when :up   then announce "migrated (%.4fs)" % time.real; write
    when :down then announce "reverted (%.4fs)" % time.real; write
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

require 'card/core_migration'
