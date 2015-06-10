require 'optparse'
require 'active_support/core_ext/object/inclusion' # adds method in? to Object class 

def load_rake_tasks
  require './config/environment'
  require 'rake'
  Wagn::Application.load_tasks
end

RAILS_COMMANDS = %w( generate destroy plugin benchmarker profiler console server dbconsole application runner )
ALIAS = {
  'rs' => 'rspec',
  'cc' => 'cucumber',
  'jm' => 'jasmine',
  'g'  => 'generate',
  'd'  => 'destroy',
  'c'  => 'console',
  's'  => 'server',
  'db' => 'dbconsole',
  'r'  => 'runner'
}

ARGV << '--help' if ARGV.empty?

def supported_rails_command? arg
  arg.in? RAILS_COMMANDS or ALIAS[arg].in? RAILS_COMMANDS
end

def find_spec_file filename, base_dir
  file, line = filename.split(':')
  if file.include? '_spec.rb' and File.exist?(file)
    filename
  else
    file = File.basename(file,".rb").sub(/_spec$/,'')
    Dir.glob("#{base_dir}/**/#{file}_spec.rb").flatten.map{ |file| line ? "#{file}:#{line}" : file}.join(' ')
  end
end

TASK_COMMANDS = %w[seed reseed load update]

if supported_rails_command? ARGV.first
  if ARGV.delete('--rescue')
    ENV["PRY_RESCUE_RAILS"]="1"
  end
  command = ARGV.first
  command = ALIAS[command] || command
  require 'generators/card' if command == 'generate' # without this, the card generators don't list with: wagn g --help
  require 'rails/commands'
else
  command = ARGV.shift
  command = ALIAS[command] || command

  case command
  when *TASK_COMMANDS
    envs = []
    parser = OptionParser.new do |parser|
      parser.banner = "Usage: wagn #{command} [options]\n\nRun wagn:#{command} task on the production database specified in config/database.yml\n\n"
      parser.on('--production','-p', "#{command} production database (default)") do
        envs = ['production']
      end
      parser.on('--test','-t', "#{command} test database") do
        envs = ['test']
      end
      parser.on('--development', '-d', "#{command} development database") do
        envs = ['development']
      end
      parser.on('--all', '-a', "#{command} production, test, and development database") do
        envs = %w( production development test)
      end
    end
    parser.parse!(ARGV)
    task_cmd="bundle exec rake wagn:#{command}"
    if envs.empty?
      puts task_cmd
      puts `#{task_cmd}`
    else
      envs.each do |env|
        puts "env RAILS_ENV=#{env} #{task_cmd}"
        puts `env RAILS_ENV=#{env} #{task_cmd}`
      end
    end
#  when 'update'
#    load_rake_tasks
#    Rake::Task['wagn:update'].invoke
  when 'cucumber'
    require 'wagn'
    require './config/environment'
    feature_paths = Card::Loader.mod_dirs.map do |p|
      Dir.glob "#{p}/features"
    end.flatten
    require_args = "-r #{Wagn.gem_root}/features "
    require_args += feature_paths.map { |path| "-r #{path}"}.join(' ')
    feature_args = ARGV.empty? ? feature_paths.join(' ') : ARGV.join(' ')
    unless system "RAILS_ROOT=. bundle exec cucumber #{require_args} #{feature_args} 2>&1"
      exit $?.exitstatus
    end
  when 'jasmine'
    unless system "RAILS_ENV=test bundle exec rake spec:javascript 2>&1"
      exit $?.exitstatus
    end
  when 'rspec'
    opts = {}
    require 'rspec/core'
    require 'wagn/application'
    parser = RSpec::Core::Parser.new.parser(opts)
    parser.banner = "Usage: wagn rspec [WAGN ARGS] -- [RSPEC ARGS]\n\nRSPEC ARGS"
    parser.separator <<-WAGN

WAGN ARGS

  You don't have to give a full path for FILENAME, the basename is enough
  If FILENAME does not include '_spec' rspec searches for the corresponding spec file.
  The line number always referes to example in the (corresponding) spec file.

WAGN

    parser.on('-d', '--spec FILENAME(:LINE)', 'Run spec for a Wagn deck file') do |file|
      opts[:files] = find_spec_file( file, "#{Wagn.root}/mod")
    end
    parser.on('-c', '--core-spec FILENAME(:LINE)', 'Run spec for a Wagn core file') do |file|
      opts[:files] = find_spec_file( file, Cardio.gem_root)
    end
    parser.on('-m', '--mod MODNAME', 'Run all specs for a mod or matching a mod') do |file|
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

    before_split = true
    wagn_args, rspec_args = ARGV.partition {|a| before_split = a=='--' ? false : before_split}
    rspec_args.shift

    parser.parse!(wagn_args)

    rspec_command = "RAILS_ROOT=. #{opts[:simplecov]} #{opts[:executer]} #{opts[:rescue]} rspec #{rspec_args*' '} #{opts[:files]} 2>&1" 
    unless system rspec_command
      exit $?.exitstatus
    end
  when '--version', '-v'
    puts "Wagn #{Card::Version.release}"
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


