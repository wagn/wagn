# -*- encoding : utf-8 -*-

require "generators/card"

class Card
  module Generators
    class TemplateGenerator < NamedBase
      source_root File.expand_path("../templates", __FILE__)

      argument :set_pattern, required: true
      argument :anchors, required: true, type: :array
      class_option "core", type: :boolean, aliases: "-c",
                   default: false, group: :runtime,
                   desc: "create haml template in Card gem"

      def create_files
        with_valid_arguments do
          template "haml_template.erb", set_path
        end
      end

      private

      def with_valid_arguments
        if !Dir.exist? mod_path
          warn "Directory #{mod_path} doesn't exist. Is '#{file_name}' a valid mod name?"
        elsif !%w[self type type_plus_right ltype_rtype rstar star
                  type all_plus all ].include? set_pattern
          warn "not a valid set pattern: #{set_pattern}"
        else
          yield
        end
      end

      def set_path
        filename = "#{anchors.last}.haml"
        dirs = anchors[0..-2]
        path_parts = [mod_path, "template", set_pattern, dirs, filename]
        File.join(*path_parts.compact)
      end
    end
  end
end
