# -*- encoding : utf-8 -*-
require "optparse"

module Wagn
  module Commands
    class CucumberCommand
      class Parser < OptionParser
        def initialize opts
          super() do |parser|
            parser.banner = "Usage: wagn cucumber [WAGN ARGS] -- [CUCUMBER ARGS]\n\n"
            parser.separator <<-EOT.strip_heredoc

               WAGN ARGS
            EOT
            opts[:env] = ["RAILS_ROOT=."]
            parser.on("-d", "--debug", "Drop into debugger on failure") do |a|
              opts[:env] << "DEBUG=1" if a
            end
            parser.on("-f", "--fast", "Stop on first failure") do |a|
              opts[:env] << "FAST=1" if a
            end
            parser.on("-l", "--launchy", "Open page on failure") do |a|
              opts[:env] << "LAUNCHY=1" if a
            end
            parser.on("-s", "--step", "Pause after each step") do |a|
              opts[:env] << "STEP=1" if a
            end
          end
        end
      end
    end
  end
end
