# -*- encoding : utf-8 -*-

class Wagn::Migration < ActiveRecord::Migration
  def self.core_card_migration_paths
    Wagn.paths['db/migrate_core_cards'].to_a
  end
  
  def self.deck_card_migration_paths
    Wagn.paths['db/migrate_deck_cards'].to_a
  end
  
  def self.schema_mode type
    new_suffix = case type.to_s 
    when /card/ then '_cards'
    when /deck/ then '_deck_cards'
    else ''
    end
    original_suffix = ActiveRecord::Base.table_name_suffix
    ActiveRecord::Base.table_name_suffix = new_suffix
    yield
    ActiveRecord::Base.table_name_suffix = original_suffix
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
  
  def data_path filename=nil
    if filename
      migration_paths.each do |path|
        data_path = File.join path, filename
        return data_path if File.exists? data_path
      end
    else
      migration_paths.first
    end
  end
  
  def import_json filename
    Wagn.config.action_mailer.perform_deliveries = false
    raw_json = File.read( data_path filename ) 
    json = JSON.parse raw_json
    Card.merge_list json["card"]["value"], :output_file=>File.join(data_path,"unmerged_#{ filename }")
  end
  
    
  def schema_mode
    Wagn::Migration.schema_mode :deck
  end
  
  def migration_paths
    Wagn::Migration.deck_card_migration_paths
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
