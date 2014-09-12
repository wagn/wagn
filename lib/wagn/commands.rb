require 'optparse'
require 'pry'
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

def format_rspec_file filename, base_dir
  file, line = filename.split(':')
  file = File.basename(file,".rb")
  binding.pry
  Dir.glob("#{base_dir}/**/#{file}_spec.rb").flatten.map{ |file| line ? "#{file}:#{line}" : file}.join(' ')
end


def format_rspec_file_argument index, base_dir
  ARGV.delete_at(index)
  file, line = ARGV[index].split(':')
  file = File.basename(file,".rb")
  ARGV.delete_at(index)
  Dir.glob("#{base_dir}/**/#{file}_spec.rb").flatten.map{ |file| line ? "#{file}:#{line}" : file}.join(' ')
end

rails_commands = %w( generate destroy plugin benchmarker profiler console server dbconsole application runner )

if ARGV.first.in? rails_commands or aliases[ARGV.first].in? rails_commands
  require 'wagn'
  require 'rails/commands'
else
  command = ARGV.shift
  command = aliases[command] || command

  case command
  when 'seed'
    #load_rake_tasks  we can't load config/environment if the database doesn't exist, use config/application instead
    require './config/application'
    require 'wagn/migration_helper'
    require 'rake'
    Wagn::Application.load_tasks
    Rake::Task['wagn:create'].invoke
    if ARGV.include? "--test-data" 
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
    rspec_parser = OptionParser.new do |parser|
      parser.on('-s', '--spec (PART_OF)FILENAME(:LINE)', 'Run spec for a deck file') do |file|
        opts[:files] = format_rspec_file( file, "mods")
      end
      parser.on('-c', '--core-spec (PART_OF)FILENAME(:LINE)', 'Run spec for a core file') do |file|
        opts[:files] = format_rspec_file( file, "#{Wagn.gem_root}" )
      end
      parser.on('-m', '--mod MOD NAME', 'Run all spec for a mod') do |file|
        opts[:files] = "mod/#{file}"
      end
      parser.on('-r', '--rescue', 'Run with pry-rescue')
        opts[:rescue] = 'rescue '
      end
    end
    rspec_parser.parse!(ARGV)


    system "RAILS_ROOT=. bundle exec #{opts[:rescue]} rspec #{ARGV.join(' ')} #{opts[:files]}"
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
