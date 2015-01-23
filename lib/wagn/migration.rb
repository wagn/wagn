# -*- encoding : utf-8 -*-

class Wagn::Migration < ActiveRecord::Migration
  @type = :deck_cards
  
  def self.find_unused_name base_name
    test_name = base_name
    add = 1
    while Card.exists?(test_name) do
      test_name = "#{base_name}#{add}"
      add +=1
    end
    test_name
  end

  def self.paths
    Wagn.paths["db/migrate#{schema_suffix @type}"].to_a
  end
  
  def self.schema_suffix
    Wagn::Version.schema_suffix @type
  end
  
  def self.schema_mode
    new_suffix = Wagn::Migration.schema_suffix
    original_suffix = ActiveRecord::Base.table_name_suffix
    
    ActiveRecord::Base.table_name_suffix = new_suffix
    yield
    ActiveRecord::Base.table_name_suffix = original_suffix
  end
  
  
  def self.data_path filename=nil
    if filename
      self.paths.each do |path|
        path_to_file = File.join path, 'data', filename
        return path_to_file if File.exists? path_to_file
      end
    else
      File.join self.paths.first, 'data'
    end
  end
  
  def contentedly &block
    Wagn::Cache.reset_global
    Wagn::Migration.schema_mode '' do
      Card::Auth.as_bot do
        ActiveRecord::Base.transaction do
          begin
            yield
          ensure
            Wagn::Cache.reset_global
          end
        end
      end
    end
  end
  

  def import_json filename
    Wagn.config.action_mailer.perform_deliveries = false
    raw_json = File.read( data_path filename ) 
    json = JSON.parse raw_json
    Card.merge_list json["card"]["value"], :output_file=>File.join(data_path,"unmerged_#{ filename }")
  end
  
  def data_path filename=nil
    self.class.data_path filename
  end
    
  def schema_mode
    self.class.schema_mode 
  end
  
  def migration_paths
    self.class.paths
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
