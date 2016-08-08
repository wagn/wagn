# -*- encoding : utf-8 -*-

module Wagn
  class Parser
    class << self
      def db_task command, opts
        OptionParser.new do |parser|
          parser.banner = "Usage: wagn #{command} [options]\n\n" \
                          "Run wagn:#{command} task on the production "\
                          " database specified in config/database.yml\n\n"
          parser.on("--production", "-p",
                    "#{command} production database (default)") do
            opts[:envs] = ["production"]
          end
          parser.on("--test", "-t",
                    "#{command} test database") do
            opts[:envs] = ["test"]
          end
          parser.on("--development", "-d",
                    "#{command} development database") do
            opts[:envs] = ["development"]
          end
          parser.on("--all", "-a",
                    "#{command} production, test, and development database") do
            opts[:envs] = %w(production development test)
          end
        end
      end

      def rspec opts
        OptionParser.new do |parser|
          parser.banner = "Usage: wagn rspec [WAGN ARGS] -- [RSPEC ARGS]\n\n" \
                          "RSPEC ARGS"
          parser.separator <<-WAGN

      WAGN ARGS

        You don't have to give a full path for FILENAME, the basename is enough
        If FILENAME does not include '_spec' rspec searches for the
        corresponding spec file.
        The line number always referes to example in the (corresponding) spec
        file.

      WAGN

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
    end
  end
end
