# if Wagn.config.performance_logger
#   Card::Log::Performance.load_config Wagn.config.performance_logger
# end

if Wagn.config.performance_logger &&  (!Wagn.config.performance_logger[:methods] || Wagn.config.performance_logger[:methods].include?(:execute))
  module ActiveRecord
    module ConnectionAdapters
      class AbstractMysqlAdapter
        alias_method :original_execute, :execute
        def execute(sql, name = nil)
          Card.with_logging :execute, :message=>'SQL', :details=>sql, :category=>'SQL' do
            original_execute(sql, name)
          end
        end
      end
    end
  end
end