# -*- encoding : utf-8 -*-

require 'generators/card'

class Card
  module Generators
    class FormatGenerator < NamedBase
      source_root File.expand_path('../templates', __FILE__)

      def create_files
        template 'format_template.erb',           "mod/05_standard/format/#{file_name}_format.rb"
        template 'format_spec_template.erb', "spec/mod/05_standard/format/#{file_name}_format_spec.rb"
      end
    end
  end
end
