# -*- encoding : utf-8 -*-
require "optparse"

module Wagn
  module Commands
    class RspecCommand
      class Parser < OptionParser
        def initialize opts
          super() do |parser|
            parser.banner = "Usage: wagn cucumber [WAGN ARGS] -- [CUCUMBER ARGS]\n\n"
            # parser.separator <<-EOT
            #
            # WAGN ARGS
            #
            # You don't have to give a full path for FILENAME, the basename is enough
            #   If FILENAME does not include '_spec' rspec searches for the
            #   corresponding spec file.
            #   The line number always referes to example in the (corresponding) spec
            #   file.
            #
            # EOT

            parser.on("-d", "--debug", "Drop into debugger on failure") do |a|
              opts[:debug] = a ? "DEBUG=1" : ""
            end
            parser.on("-f", "--fast", "Stop on first failure") do |a|
              opts[:fast] = a ? "FAST=1" : ""
            end
            parser.on("-l", "--launchy", "Open page on failure") do |a|
              opts[:launchy] = a ? "LAUNCHY=1" : ""
            end
            parser.on("-s", "--step", "Pause after each step") do |a|
              opts[:step] = a ? "STEP=1" : ""
            end
          end
        end
      end
    end
  end
end
