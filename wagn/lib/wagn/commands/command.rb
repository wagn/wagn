module Wagn
  module Commands
    class Command
      def run
        puts command
        exit_with_child_status command
      end

      def exit_with_child_status command
        command += " 2>&1"
        exit $CHILD_STATUS.exitstatus unless system command
      end

      # split special wagn args and original command args separated by '--'
      def split_args args
        before_split = true
        wagn_args, command_args =
          args.partition do |a|
            before_split = (a == "--" ? false : before_split)
          end
        command_args.shift
        [wagn_args, command_args]
      end
    end
  end
end
