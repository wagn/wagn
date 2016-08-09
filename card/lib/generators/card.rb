# -*- encoding : utf-8 -*-

require "rails/generators"
require "rails/generators/active_record"

class Card
  module Generators
    module ClassMethods
      def source_root path=nil
        if path
          @_card_source_root = path
        else
          @_card_source_root ||= File.expand_path(File.join(File.dirname(__FILE__), "card", generator_name, "templates"))
        end
      end

      # Override Rails default banner (wagn is the command name).
      def banner
        "wagn generate #{namespace} #{arguments.map(&:usage) * ' '} [options]".gsub(/\s+/, " ")
      end
    end

    class NamedBase < ::Rails::Generators::NamedBase
      extend ClassMethods
    end
    class MigrationBase < ::ActiveRecord::Generators::Base
      extend ClassMethods
    end
  end
end
