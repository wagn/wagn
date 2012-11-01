require 'rake'

# This code lets us redefine existing Rake tasks, which is extremely
# handy for modifying existing Rails rake tasks.
# Credit for the original snippet of code goes to Jeremy Kemper
# http://pastie.caboo.se/9620
unless Rake::TaskManager.methods.include?(:redefine_task)
  module Rake
    module TaskManager
      def redefine_task(task_class, args, &block)
        task_name, arg_names, deps = resolve_args(args)
        task_name = task_class.scope_name(@scope, task_name)
        deps = [deps] unless deps.respond_to?(:to_ary)
        deps = deps.collect {|d| d.to_s }
        task = @tasks[task_name.to_s] = task_class.new(task_name, self)
        task.application = self
        @last_comment = nil
        task.enhance(deps, &block)
        task
      end
    end
    class Task
      class << self
        def redefine_task(args, &block)
          Rake.application.redefine_task(self, [args], &block)
        end
      end
    end
  end
end

namespace :db do
  namespace :test do
    desc 'Prepare the test database and load the schema'
    Rake::Task.redefine_task( :prepare => :environment ) do
      if ENV['RELOAD_TEST_DATA'] == 'true' || ENV['RUN_CODE_RUN']
        puts `env RAILS_ENV=test rake wagn:create`
      else
        puts "skipping loading test data.  to force, run  env RELOAD_TEST_DATA=true rake db:test:prepare"
      end
    end
  end

  desc 'Run migrations and then write the version to a file'
  task :migrate_and_stamp => :environment do
    Rake::Task['db:migrate'].invoke
    stamp_file = Wagn::Application.config.paths['config/database'].first.sub(/[^\/]*$/,'version.txt')
    version = ActiveRecord::Migrator.current_version
    puts ">>  writing version: #{version} to #{stamp_file}"
    if file = open(stamp_file, 'w')
      file.puts version
    end
    Wagn::Cache.reset_global
  end
end
