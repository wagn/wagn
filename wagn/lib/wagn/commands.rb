require "optparse"

# add method in? to Object class
require "active_support/core_ext/object/inclusion"
require "wagn/parser"

def load_rake_tasks
  require "./config/environment"
  require "rake"
  Wagn::Application.load_tasks
end

RAILS_COMMANDS = %w( generate destroy plugin benchmarker profiler console
                     server dbconsole application runner ).freeze
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

ARGV << "--help" if ARGV.empty?

def supported_rails_command? arg
  arg.in?(RAILS_COMMANDS) || ALIAS[arg].in?(RAILS_COMMANDS)
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

def exit_with_child_status command
  command += " 2>&1"
  exit $CHILD_STATUS.exitstatus unless system command
end

WAGN_DB_TASKS = %w(seed reseed load update).freeze

if supported_rails_command? ARGV.first
  ENV["PRY_RESCUE_RAILS"] = "1" if ARGV.delete("--rescue")
  command = ARGV.first
  command = ALIAS[command] || command

  # without this, the card generators don't list with: wagn g --help
  require "generators/card" if command == "generate"
  require "rails/commands"
else
  command = ARGV.shift
  command = ALIAS[command] || command

  case command
  when "cucumber"
    require "wagn"
    require "./config/environment"
    feature_paths = Card::Loader.mod_dirs.map do |p|
      Dir.glob "#{p}/features"
    end.flatten
    require_args = "-r #{Wagn.gem_root}/features "
    require_args += feature_paths.map { |path| "-r #{path}" }.join(" ")
    feature_args = ARGV.empty? ? feature_paths.join(" ") : ARGV.shelljoin
    exit_with_child_status "RAILS_ROOT=. bundle exec cucumber " \
                           "#{require_args} #{feature_args}"
  when "jasmine"
    exit_with_child_status "RAILS_ENV=test bundle exec rake spec:javascript"
  when "rspec"
    require "rspec/core"
    require "wagn/application"

    before_split = true
    wagn_args, rspec_args =
      ARGV.partition do |a|
        before_split = (a == "--" ? false : before_split)
      end
    rspec_args.shift
    opts = {}
    Wagn::Parser.rspec(opts).parse!(wagn_args)

    rspec_command =
      "RAILS_ROOT=. #{opts[:simplecov]} #{opts[:executer]} " \
      " #{opts[:rescue]} rspec #{rspec_args.shelljoin} #{opts[:files]}"
    exit_with_child_status rspec_command
  when "--version", "-v"
    puts "Wagn #{Card::Version.release}"
  when "new"
    if ARGV.first.in?(["-h", "--help"])
      require "wagn/commands/application"
    else
      puts "Can't initialize a new deck within the directory of another, " \
           "please change to a non-deck directory first.\n"
      puts "Type 'wagn' for help."
      exit(1)
    end
  when *WAGN_DB_TASKS
    opts = {}
    Wagn::Parser.db_task(command, opts).parse!(ARGV)
    task_cmd = "bundle exec rake wagn:#{command}"
    if !opts[:envs] || opts[:envs].empty?
      puts task_cmd
      puts `#{task_cmd}`
    else
      opts[:envs].each do |env|
        puts "env RAILS_ENV=#{env} #{task_cmd}"
        puts `env RAILS_ENV=#{env} #{task_cmd}`
      end
    end

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
