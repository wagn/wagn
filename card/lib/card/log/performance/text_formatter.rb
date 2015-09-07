class Card::Log::Performance
  class TextFormatter
    def initialize log_entries, time_per_category
      @log = log_entries
      @time_per_category = time_per_category
    end

    def output
      @output ||= "#{category_summary}\n\n  #{details}"
    end


    def details
      @details ||=
        @log.each_with_object('') do |entry, str|
          str += entry.to_s! if entry.valid
        end
    end


    def category_summary
      @category_summary ||=
        @time_per_category.keys.map do |key|
          "#{key}: #{@time_per_category[key]}"
        end.join "\n"
    end

  end
end