require "rake"

# This code lets us redefine existing Rake tasks, which is extremely
# handy for modifying existing Rails rake tasks.
# Credit for the original snippet of code goes to Jeremy Kemper
# http://pastie.caboo.se/9620
unless Rake::TaskManager.methods.include?(:redefine_task)
  module Rake
    module TaskManager
      def redefine_task task_class, args, &block
        task_name, arg_names, deps = resolve_args(args)
        task_name = task_class.scope_name(@scope, task_name)
        deps = [deps] unless deps.respond_to?(:to_ary)
        deps = deps.map(&:to_s)
        task = @tasks[task_name.to_s] = task_class.new(task_name, self)
        task.application = self
        @last_comment = nil
        task.enhance(deps, &block)
        task
      end
    end
    class Task
      class << self
        def redefine_task args, &block
          Rake.application.redefine_task(self, [args], &block)
        end
      end
    end
  end
end

namespace :db do
  namespace :fixtures do
    desc "Load fixtures into the current environment's database.  Load specific fixtures using FIXTURES=x,y"
    task load: :environment do
      require "active_record/fixtures"
      fixture_path = File.join(Cardio.gem_root, "db", "seed", "test", "fixtures")
      ActiveRecord::Base.establish_connection(::Rails.env.to_sym)
      (ENV["FIXTURES"] ? ENV["FIXTURES"].split(/,/) : Dir.glob(File.join(fixture_path, "*.{yml,csv}"))).each do |fixture_file|
        ActiveRecord::FixtureSet.create_fixtures(fixture_path, File.basename(fixture_file, ".*"))
      end
    end
  end

  namespace :test do
    desc "Prepare the test database and load the schema"
    Rake::Task.redefine_task(prepare: :environment) do
      if ENV["RELOAD_TEST_DATA"] == "true" || ENV["RUN_CODE_RUN"]
        puts `env RAILS_ENV=test rake wagn:seed`
      else
        puts "skipping loading test data.  to force, run `env RELOAD_TEST_DATA=true rake db:test:prepare`"
      end
    end
  end
end
