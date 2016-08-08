# -*- encoding : utf-8 -*-

require "generators/card"

class Card
  module Generators
    class FormatGenerator < NamedBase
      source_root File.expand_path("../templates", __FILE__)

      argument :module_name, required: true
      class_option "core", type: :boolean, aliases: "-c", default: false, group: :runtime,
                           desc: "create format files in Card gem"

      def create_files
        mod_path = if options.core?
                     File.join Cardio.gem_root, "mod", file_name
                   else
                     File.join "mod", file_name
          end
        format_path = File.join(mod_path, "format", "#{module_name}_format.rb")
        spec_path = File.join(mod_path, "spec", "format", "#{module_name}_format_spec.rb")
        template "format_template.erb", format_path
        template "format_spec_template.erb", spec_path
      end
    end
  end
end
