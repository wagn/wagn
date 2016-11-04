

# add method in? to Object class
require "active_support/core_ext/object/inclusion"
require "wagn/commands/parser"

def load_rake_tasks
  require "./config/environment"
  require "rake"
  Wagn::Application.load_tasks
end

RAILS_COMMANDS = %w( generate destroy plugin benchmarker profiler console
                     server dbconsole application runner ).freeze
WAGN_COMMANDS = %w(new cucumber rspec jasmine).freeze
WAGN_DB_COMMANDS = %w(seed reseed load update).freeze

ALIAS = {
  "rs" => "rspec",
  "cc" => "cucumber",
  "jm" => "jasmine",
  "g"  => "generate",
  "d"  => "destroy",
  "c"  => "console",
  "s"  => "server",
  "db" => "dbconsole",
  "r"  => "runner"
}.freeze

def supported_rails_command? arg
  arg.in?(RAILS_COMMANDS) || ALIAS[arg].in?(RAILS_COMMANDS)
end

def run_new
  if ARGV.first.in?(["-h", "--help"])
    require "wagn/commands/application"
  else
    puts "Can't initialize a new deck within the directory of another, " \
           "please change to a non-deck directory first.\n"
    puts "Type 'wagn' for help."
    exit(1)
  end
end

def run_rspec
  require "wagn/commands/rspec_command"
  Wagn::Commands::RspecCommand.new(ARGV).run
end

def run_cucumber
  require "wagn/commands/cucumber_command"
  Wagn::Commands::CucumberCommand.new(ARGV).run
end

def run_db_task command
  require "wagn/commands/rake_command"
  opts = {}
  Wagn::Commands::Parser.db_task(command, opts).parse!(ARGV)
  Wagn::Commands::RakeCommand.new("wagn:#{command}", opts).run
end

def run_jasmine
  require "wagn/commands/rake_command"
  Wagn::Commands::RakeCommand.new("spec:javascript", envs: "test").run
end

ARGV << "--help" if ARGV.empty?

command = ARGV.first
command = ALIAS[command] || command
if supported_rails_command? command
  ENV["PRY_RESCUE_RAILS"] = "1" if ARGV.delete("--rescue")

  # without this, the card generators don't list with: wagn g --help
  require "generators/card" if command == "generate"
  require "rails/commands"
else
  ARGV.shift
  case command
  when "--version", "-v"
    puts "Wagn #{Card::Version.release}"
  when *WAGN_COMMANDS
    send("run_#{command}")
  when *WAGN_DB_COMMANDS
    run_db_task command
  else
    puts "Error: Command not recognized" unless command.in?(["-h", "--help"])
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
   load         Load bootstrap data into database

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
