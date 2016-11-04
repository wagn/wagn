require File.expand_path("../command", __FILE__)

module Wagn
  module Commands
    class RakeCommand < Command
      def initialize rake_task, opts={}
        @task = rake_task
        @envs = Array(opts[:envs])
      end

      def run
        command.each do |cmd|
          puts cmd
          puts `#{cmd}`
        end
      end

      def command
        task_cmd = "bundle exec rake #{@task}"
        return [task_cmd] if !@envs || @envs.empty?
        @envs.map do |env|
          "env RAILS_ENV=#{env} #{task_cmd}"
        end
      end
    end
  end
end
