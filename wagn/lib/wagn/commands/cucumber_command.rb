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
        @args = args
      end

      def command
        @cmd ||=
          "#{env_args} bundle exec cucumber #{require_args} #{feature_args}"
      end

      private

      def env_args
        env_args = "RAILS_ROOT=."
        env_args << " COVERAGE=false" if @args.present?
        env_args
      end

      def feature_args
        @args.empty? ? feature_paths.join(" ") : @args.shelljoin
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
