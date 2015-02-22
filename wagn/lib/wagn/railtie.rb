
require 'decko/engine'
require 'rails/all'

module Wagn
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
      #puts "put insert rt"
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
