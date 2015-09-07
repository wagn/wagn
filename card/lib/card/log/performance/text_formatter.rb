class TextFormatter
  def initialize performance_logger
    @log = performance_logger.log
    @category_log = performance_logger.category_log
  end

  def output
    @output ||= "#{details}\n#{category_summary}\n"
  end


  def details
    @details ||=
      @log.select { |entry| entry.valid }.map do |entry|
        entry.to_s!
      end.join "\n"
  end


  def category_summary
    @category_summary ||=
      begin
        total = 0
        output = ''
        @category_log.each_pair do |category, time|
          total += time
          output << "%s: %d.2ms\n" % [category, time]
        end
        output << "total: %d.2ms" % total
        output
      end
  end

end