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
          @_card_source_root ||= File.expand_path(
            File.join(File.dirname(__FILE__),
                      "card", generator_name, "templates")
          )
        end
      end

      # Override Rails default banner (wagn is the command name).
      def banner
        usage_arguments = arguments.map(&:usage) * " "
        text = "wagn generate #{namespace} #{usage_arguments} [options]"
        text.gsub(/\s+/, " ")
      end
    end

    class NamedBase < ::Rails::Generators::NamedBase
      extend ClassMethods

      def mod_path
        @mod_path ||= begin
          path_parts = ["mod", file_name]
          path_parts.unshift Cardio.gem_root if options.core?
          File.join(*path_parts)
        end
      end
    end

    class MigrationBase < ::ActiveRecord::Generators::Base
      extend ClassMethods
    end
  end
end
