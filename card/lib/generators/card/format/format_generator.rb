# -*- encoding : utf-8 -*-

require "generators/card"

class Card
  module Generators
    class FormatGenerator < NamedBase
      source_root File.expand_path("../templates", __FILE__)

      argument :module_name, required: true
      class_option "core", type: :boolean, aliases: "-c",
                           default: false, group: :runtime,
                           desc: "create format files in Card gem"

      def create_files
        template "format_template.erb", format_path
        template "format_spec_template.erb", format_path("spec")
      end

      def format_path modifier=nil
        suffix = modifier ? "_#{modifier}" : nil
        filename = "#{module_name}_format#{suffix}.rb"
        path_parts = [mod_path, modifier, "format", filename].compact
        File.join(*path_parts)
      end
    end
  end
end
