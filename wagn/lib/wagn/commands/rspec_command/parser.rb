# -*- encoding : utf-8 -*-
require "optparse"

module Wagn
  module Commands
    class RspecCommand
      class Parser < OptionParser
        def initialize opts
          super() do |parser|
            parser.banner = "Usage: wagn rspec [WAGN ARGS] -- [RSPEC ARGS]\n\n" \
                            "RSPEC ARGS"
            parser.separator <<-EOT

            WAGN ARGS

            You don't have to give a full path for FILENAME, the basename is enough
              If FILENAME does not include '_spec' rspec searches for the
              corresponding spec file.
              The line number always referes to example in the (corresponding) spec
              file.

            EOT

            parser.on("-d", "--spec FILENAME(:LINE)",
                      "Run spec for a Wagn deck file") do |file|
              opts[:files] = find_spec_file(file, "#{Wagn.root}/mod")
            end
            parser.on("-c", "--core-spec FILENAME(:LINE)",
                      "Run spec for a Wagn core file") do |file|
              opts[:files] = find_spec_file(file, Cardio.gem_root)
            end
            parser.on("-m", "--mod MODNAME",
                      "Run all specs for a mod or matching a mod") do |file|
              opts[:files] =
                if File.exist?("mod/#{file}")
                  "#{Cardio.gem_root}/mod/#{file}"
                elsif File.exist?("#{Cardio.gem_root}/mod/#{file}")
                  "#{Cardio.gem_root}/mod/#{file}"
                elsif (files = find_spec_file(file, "mod")) && files.present?
                  files
                else
                  find_spec_file(file, "#{Cardio.gem_root}/mod")
                end
            end
            parser.on("-s", "--[no-]simplecov", "Run with simplecov") do |s|
              opts[:simplecov] = s ? "" : "COVERAGE=false"
            end
            parser.on("--rescue", "Run with pry-rescue") do
              if opts[:executer] == "spring"
                puts "Disabled pry-rescue. Not compatible with spring."
              else
                opts[:rescue] = "rescue "
              end
            end
            parser.on("--[no-]spring", "Run with spring") do |spring|
              if spring
                opts[:executer] = "spring"
                if opts[:rescue]
                  opts[:rescue] = ""
                  puts "Disabled pry-rescue. Not compatible with spring."
                end
              else
                opts[:executer] = "bundle exec"
              end
            end
            parser.separator "\n"
          end
        end

        def find_spec_file filename, base_dir
          file, line = filename.split(":")
          if file.include?("_spec.rb") && File.exist?(file)
            filename
          else
            file = File.basename(file, ".rb").sub(/_spec$/, "")
            Dir.glob("#{base_dir}/**/#{file}_spec.rb").flatten.map do |spec_file|
              line ? "#{spec_file}:#{line}" : file
            end.join(" ")
          end
        end
      end
    end
  end
end
