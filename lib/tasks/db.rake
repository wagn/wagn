require 'rake'

def check_for_fulltext_schema
  schema_error = ("Oops! Attempt to load a schema with a broken cards table.  Rails can't properly dump and restore a schema with fulltext index data (indexed_content). " +
    "you'll need to connect to a database without these fields and rerun >rake db:schema:dump first.")
  begin 
    # it would be good to do a test here, but it has to see whether the type is tsvector now, because cards should always have indexed_content.
    
#    if Card.columns.map(&:name).include?('indexed_content')
#      raise(schema_error)
#    end
  rescue
    raise(schema_error)
  end
end

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
      if ENV['RELOAD_TEST_DATA'] == 'true'
        check_for_fulltext_schema        
        if defined?(ActiveRecord::Base) && !ActiveRecord::Base.configurations.blank?  
          puts ">>loading db:test structure"
          Rake::Task[{ :sql  => "db:test:clone_structure", :ruby => "db:test:clone" }[ActiveRecord::Base.schema_format]].invoke
        end 
        puts ">>loading test fixtures"
        puts `rake db:fixtures:load RAILS_ENV=test`
      end
    end
  end
end