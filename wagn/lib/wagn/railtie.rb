
#require 'wagn'
#require 'cardio'
puts "loading w rt 1 #{defined? Rails}, #{defined? Card}, #{defined? Cardio}, #{defined? Decko}"
require 'decko/engine'
require 'rails/all'
puts "loading w rt 2 #{defined? Rails::Railtie}, #{defined? Card}, #{defined? Cardio}, #{defined? Decko}"

module Wagn
  warn "defined? #{defined? ::Rails::Railtie}"
  if defined? ::Rails::Railtie
    require 'rails'
    class Railtie < Rails::Railtie

=begin
      initializer 'wagn.connect_on_load' do
        ActiveSupport.on_load(:after_initialize) do
          puts "connect on load"
          begin
            puts "card #{defined? Card}"
            require_dependency 'card' unless defined? Card
          rescue ActiveRecord::StatementInvalid => e
            puts "db unavailable:#{::Rails.env}, #{e}, #{e.backtrace*"\n"}"
            ::Rails.logger.warn "database not available[#{::Rails.env}] #{e}"
          end
        end
      end
=end

      initializer 'wagn.rails_paths' do
        ActiveSupport.on_load :before_initialize do
        puts "XXXXXXXXXXXXXX auto paths #{Cardio.gem_root}, #{config.object_id}, #{config.class}, #{Wagn.application.config.object_id}, #{Wagn.application.config.class}"
        #config.autoload_paths += Dir['rails/lib/**/']
        end
      end

      # Remove me unless we actually use it
      initializer 'wagn.insert_into_active_record' do
        ActiveSupport.on_load :active_record do
          Wagn::Railtie.insert
        end
      end
    end
  end

  class Railtie
    def self.insert
  puts "put insert rt"
      # add the option first
      #Decko.options[:logger] = Rails.logger if defined?(Rails)
      
      # should this load engine, etc.?  Might be cleaner to put config stuff here?
      #if defined?(ActiveRecord)
        #ActiveRecord::Base.send(:include, Decko::Glue)
        #Decko.options[:logger] = ActiveRecord::Base.logger
      #end

    end
  end
end
