require File.expand_path("../command", __FILE__)

module Wagn
  module Commands
    class RspecCommand < Command
      def initialize args
        require "rspec/core"
        require "wagn/application"

        @wagn_args, @rspec_args = split_wagn_and_rspec_args args
        @opts = {}
        Parser.rspec(@opts).parse!(@wagn_args)
      end

      def command
        "#{env_args} #{@opts[:executer]} " \
          " #{@opts[:rescue]} rspec #{@rspec_args.shelljoin} #{@opts[:files]} "\
          " --exclude-pattern \"./card/vendor/**/*\""
      end

      private

      def env_args
        ["RAILS_ROOT=.", coverage].compact.join " "
      end

      def coverage
        # no coverage if rspec was started with file argument
        if (@opts[:files] || @rspec_args.present?) && !@opts[:simplecov]
          @opts[:simplecov] = "COVERAGE=f alse"
        end
        @opts[:simplecov]
      end

      def split_wagn_and_rspec_args args
        before_split = true
        wagn, rspec =
          args.partition do |a|
            before_split = (a == "--" ? false : before_split)
          end
        rspec.shift
        [wagn, rspec]
      end
    end
  end
end
