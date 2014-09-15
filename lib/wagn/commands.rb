require 'optparse'

def load_rake_tasks
  require './config/environment'
  require 'rake'
  Wagn::Application.load_tasks
end

require 'active_support/core_ext/object/inclusion' # adds method in? to Object class

ARGV << '--help' if ARGV.empty?

aliases = {
  "rs" => "rspec",
  "cc" => "cucumber",
  "g"  => "generate",
  "d"  => "destroy",
  "c"  => "console",
  "s"  => "server",
  "db" => "dbconsole",
  "r"  => "runner"
}

def find_spec_file filename, base_dir
  file, line = filename.split(':')
  if File.exist? file
    filename
  else
    file = File.basename(file,".rb").sub(/_spec$/,'')
    Dir.glob("#{base_dir}/**/#{file}_spec.rb").flatten.map{ |file| line ? "#{file}:#{line}" : file}.join(' ')
  end
end

5
rails_commands = %w( generate destroy plugin benchmarker profiler console server dbconsole application runner )

if ARGV.first.in? rails_commands or aliases[ARGV.first].in? rails_commands
  if ARGV.delete('--rescue')
    ENV["PRY_RESCUE_RAILS"]="1"
  end
  require 'wagn'
  require 'rails/commands'
else
  command = ARGV.shift
  command = aliases[command] || command

  case command
  when 'seed'
    options = {}
    parser = OptionParser.new do |parser|
      parser.banner = "Usage: wagn seed [options]\n\nCreate and seed the database specified in config/database.yml\n\n"
      parser.on('--test-data', 'seed also the test database') do |test|
        options[:prepare_test] = true
      end
    end
    parser.parse!(ARGV)
    
    #load_rake_tasks  we can't load config/environment if the database doesn't exist, use config/application instead
    require './config/application'
    require 'wagn/migration_helper'
    require 'rake'
    Wagn::Application.load_tasks
    Rake::Task['wagn:create'].invoke
    if options[:prepare_test]
      ENV['RELOAD_TEST_DATA'] = 'true'
      Rake::Task['db:test:prepare'].invoke
    end
  when 'update'
    load_rake_tasks
    Rake::Task['wagn:update'].invoke
  when 'cucumber'
    system "RAILS_ROOT=. bundle exec cucumber #{ ARGV.join(' ') }"
  when 'rspec'
    opts = {}
    require 'rspec/core'
    parser = RSpec::Core::Parser.new.parser(opts)
    #rspec_parser= tmp.parser(ARGV)
    
    #rspec_parser = OptionParser.new do |parser|
      parser.banner = "Usage: wagn rspec [ARGS]"
      
      parser.separator <<-WAGN 

  **** Extra Wagn options ****

  You don't have to give a full path for FILENAME, the basename is enough
  If FILENAME does not include '_spec' rspec searches for the corresponding spec file.
  The line number always referes to example in the (corresponding) spec file.

WAGN
    parser.on('-d', '--deck-spec FILENAME(:LINE)', 'Run spec for a Wagn deck file') do |file|
      opts[:files] = find_spec_file( file, "mods")
    end
    parser.on('-c', '--core-spec FILENAME(:LINE)', 'Run spec for a Wagn core file') do |file|
      opts[:files] = find_spec_file( file, "#{Wagn.gem_root}" )
    end
    parser.on('-m', '--mod MODNAME', 'Run all specs for a mod') do |file|
      opts[:files] = "mod/#{file}"
    end
    parser.on('-s', '--[no-]simplecov', 'Run with simplecov') do |s|
      opts[:simplecov] = s ? '' : 'COVERAGE=false'
    end
    parser.on('--rescue', 'Run with pry-rescue') do
      opts[:rescue] = 'rescue '
    end
    parser.separator "\n"

    wagn_args, rspec_args = (' '<<ARGV.join(' ')).split(' -- ')
    parser.parse!(wagn_args.split(' '))

    system "RAILS_ROOT=. #{opts[:simplecov]} bundle exec #{opts[:rescue]} rspec #{rspec_args} #{opts[:files]}"
  when 'server'
    
  when '--version', '-v'
    puts "Wagn #{Wagn::Version.release}"
  when 'new'
    if ARGV.first.in?(['-h', '--help'])
      require 'wagn/commands/application'
    else
      puts "Can't initialize a new deck within the directory of another, please change to a non-deck directory first.\n"
      puts "Type 'wagn' for help."
      exit(1)
    end

  else
    puts "Error: Command not recognized" unless command.in?(['-h', '--help'])
    puts <<-EOT
  Usage: wagn COMMAND [ARGS]

  The most common wagn commands are:
   new         Create a new Wagn deck. "wagn new my_deck" creates a
               new deck called MyDeck in "./my_deck"
   seed        Create and seed the database specified in config/database.yml
   
   server      Start the Rails server (short-cut alias: "s")
   console     Start the Rails console (short-cut alias: "c")
   dbconsole   Start a console for the database specified in config/database.yml
               (short-cut alias: "db")
               
  For core developers
   cucumber     Run cucumber features (short-cut alias: "cc")
   rspec        Run rspec tests (short-cut alias: "rs")
   update       Run card migrations

  In addition to those, there are the standard rails commands:
   generate     Generate new code (short-cut alias: "g")
   application  Generate the Rails application code
   destroy      Undo code generated with "generate" (short-cut alias: "d")
   benchmarker  See how fast a piece of code runs
   profiler     Get profile information from a piece of code
   plugin       Install a plugin
   runner       Run a piece of code in the application environment (short-cut alias: "r")

  All commands can be run with -h (or --help) for more information.
    EOT
    exit(1)
  end
end
