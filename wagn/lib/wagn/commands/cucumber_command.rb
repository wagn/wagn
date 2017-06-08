require File.expand_path("../command", __FILE__)

module Wagn
  module Commands
    class CucumberCommand < Command
      def initialize args
        require "wagn"
        require "./config/environment"
        @wagn_args, @cucumber_args = split_args args
        @opts = {}
        Parser.new(@opts).parse!(@wagn_args)
      end

      def command
        @cmd ||=
          "#{env_args} bundle exec cucumber #{require_args} #{feature_args}"
      end

      private

      def env_args
        env_args = @opts[:env].join " "
        # turn coverage off if not all cukes run
        env_args << " COVERAGE=false" if @cucumber_args.present?
        env_args
      end

      def feature_args
        if @cucumber_args.empty?
          feature_paths.join(" ")
        else
          @cucumber_args.shelljoin
        end
      end

      def require_args
        "-r #{Wagn.gem_root}/features " +
          feature_paths.map { |path| "-r #{path}" }.join(" ")
      end

      def feature_paths
        Card::Mod::Loader.mod_dirs.map do |p|
          Dir.glob "#{p}/features"
        end.flatten
      end
    end
  end
end

require File.expand_path("../cucumber_command/parser", __FILE__)
