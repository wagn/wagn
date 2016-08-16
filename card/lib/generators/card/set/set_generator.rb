# -*- encoding : utf-8 -*-

require "generators/card"

class Card
  module Generators
    class SetGenerator < NamedBase
      source_root File.expand_path("../templates", __FILE__)

      argument :set_pattern, required: true
      argument :anchors, required: true, type: :array
      class_option "core", type: :boolean, aliases: "-c", default: false, group: :runtime,
                           desc: "create set files in Card gem"

      def create_files
        mod_path = if options.core?
                     File.join Cardio.gem_root, "mod", file_name
                   else
                     File.join "mod", file_name
          end
        set_path  = File.join(mod_path, "set", set_pattern, anchors[0..-2], "#{anchors.last}.rb")
        spec_path = File.join(mod_path, "spec", "set", set_pattern, anchors[0..-2], "#{anchors.last}_spec.rb")
        template "set_template.erb", set_path
        template "set_spec_template.erb", spec_path
      end
    end
  end
end
