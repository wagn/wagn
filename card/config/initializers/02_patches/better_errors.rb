module Patches
  module BetterErrors
    class StackFrame
      # correct links to tmp files so that they point
      # to the original file and line
      module TmpPath
        @map = {} # cache tmp path mapping

        class << self
          def included klass
            klass.class_eval do
              remove_method :initialize
            end
          end

          def corrections filename
            @map[filename] ||= real_filename_and_line_offset filename
            yield(*@map[filename])
          end

          def real_filename_and_line_offset filename
            File.open(filename) do |file|
              file.each_line.with_index do |line, i|
                if line =~ /pulled from ([\S]+) ~~/
                  return Regexp.last_match(1), i + 1
                end
              end
            end
            [filename, 0]
          end
        end

        def initialize filename, line, name, frame_binding=nil
          @filename = filename
          @line = line
          @name = name
          @frame_binding = frame_binding

          correct_tmp_file if tmp_file?
          set_pretty_method_name if frame_binding
        end

        def tmp_file?
          @filename.include? "/tmp/"
        end

        def correct_tmp_file
          TmpPath.corrections(@filename) do |real_path, line_offset|
            @filename = real_path
            @line -= line_offset
          end
        end
      end
    end
  end
end
