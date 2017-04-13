require "csv"

format :csv  do
  def default_nest_view
    :core
  end

  def default_item_view
    @depth.zero? ? :csv_row : :name
  end

  view :csv_row do
    array = _render_raw.scan(/\{\{[^\}]*\}\}/).map do |inc|
      process_content(inc).strip
    end

    CSV.generate_line(array).strip
    # strip is because search already joins with newlines
  end

  view :missing do |_args|
    ""
  end
end
