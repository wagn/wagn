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
    if ARGV.include? "-test-data" 
      ENV['RELOAD_TEST_DATA'] = 'true'
      Rake::Task['db:test:prepare'].invoke
    end
  when 'update'
    load_rake_tasks
    Rake::Taske['wagn:update'].invoke
  when 'cucumber'
    system "RAILS_ROOT=. bundle exec cucumber"
  when 'rspec'
    system "RAILS_ROOT=. bundle exec rspec"
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
   
   console     Start the Rails console (short-cut alias: "c")
   server      Start the Rails server (short-cut alias: "s")
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