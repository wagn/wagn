# -*- encoding : utf-8 -*-

require "generators/card"

class Card
  module Generators
    class SetGenerator < NamedBase
      source_root File.expand_path("../templates", __FILE__)

      argument :set_pattern, required: true
      argument :anchors, required: true, type: :array
      class_option "core", type: :boolean, aliases: "-c",
                           default: false, group: :runtime,
                           desc: "create set files in Card gem"

      def create_files
        template "set_template.erb", set_path
        template "set_spec_template.erb", set_path("spec")
      end

      private

      def set_path modifier=nil
        suffix = modifier ? "_#{modifier}" : nil
        filename = "#{anchors.last}#{suffix}.rb"
        dirs = anchors[0..-2]
        path_parts = [mod_path, modifier, "set", set_pattern, dirs, filename]
        File.join(*path_parts.compact)
      end
    end
  end
end
