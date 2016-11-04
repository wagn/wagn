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
    end
  end
end
