# -*- encoding : utf-8 -*-

require 'rails/generators'
require 'rails/generators/active_record'

class Card
  module Generators
    class NamedBase < ::Rails::Generators::NamedBase
      class << self
        def source_root(path = nil)
          if path
            @_card_source_root = path
          else
            @_card_source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'card', generator_name, 'templates'))
          end
        end

        # Override Rails default banner.
        def banner
          "wagn generate #{namespace} #{self.arguments.map(&:usage)*' '} [options]".gsub(/\s+/, ' ')
        end
      end
    end

    class MigrationBase < ::ActiveRecord::Generators::Base
      class << self
        def source_root(path = nil)
          if path
            @_card_source_root = path
          else
            @_card_source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'card', generator_name, 'templates'))
          end
        end

        # Override Rails default banner.
        def banner
          "wagn generate #{namespace} #{self.arguments.map(&:usage)*' '} [options]".gsub(/\s+/, ' ')
        end
      end
    end
  end
end

