# -*- encoding : utf-8 -*-

module Wagn
  class Parser
    class << self
      def rspec opts
        OptionParser.new do |parser|
          parser.banner = "Usage: wagn rspec [WAGN ARGS] -- [RSPEC ARGS]\n\n" \
                          'RSPEC ARGS'
          parser.separator <<-WAGN

      WAGN ARGS

        You don't have to give a full path for FILENAME, the basename is enough
        If FILENAME does not include '_spec' rspec searches for the corresponding spec file.
        The line number always referes to example in the (corresponding) spec file.

      WAGN

          parser.on('-d', '--spec FILENAME(:LINE)',
                    'Run spec for a Wagn deck file') do |file|
            opts[:files] = find_spec_file( file, "#{Wagn.root}/mod")
          end
          parser.on('-c', '--core-spec FILENAME(:LINE)',
                    'Run spec for a Wagn core file') do |file|
            opts[:files] = find_spec_file( file, Cardio.gem_root)
          end
          parser.on('-m', '--mod MODNAME',
                    'Run all specs for a mod or matching a mod') do |file|
            if File.exists? mod_path = "mod/#{file}"
              opts[:files] = "#{Cardio.gem_root}/mod/#{file}"
            elsif File.exists? mod_path = "#{Cardio.gem_root}/mod/#{file}"
              opts[:files] = "#{Cardio.gem_root}/mod/#{file}"
            elsif (opts[:files] = find_spec_file( file, "mod")).present?
            else
              opts[:files] = find_spec_file( file, "#{Cardio.gem_root}/mod")
            end
          end
          parser.on('-s', '--[no-]simplecov', 'Run with simplecov') do |s|
            opts[:simplecov] = s ? '' : 'COVERAGE=false'
          end
          parser.on('--rescue', 'Run with pry-rescue') do
            if opts[:executer] == 'spring'
              puts "Disabled pry-rescue. Not compatible with spring."
            else
              opts[:rescue] = 'rescue '
            end
          end
          parser.on('--[no-]spring', 'Run with spring') do |spring|
            if spring
              opts[:executer] = 'spring'
              if opts[:rescue]
                opts[:rescue]  = ''
                puts "Disabled pry-rescue. Not compatible with spring."
              end
            else
              opts[:executer] = 'bundle exec'
            end
          end
          parser.separator "\n"
        end
      end
    end
  end
end