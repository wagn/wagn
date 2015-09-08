def log_dir
  dir = File.join File.dirname(Wagn.paths['log'].existent.first), 'performance'
  Dir.mkdir dir unless Dir.exists? dir
  dir
end

def log_path item
  File.join log_dir, "#{item.gsub('&#47;','_').gsub(/[^0-9A-Za-z.\-]/, '_')}.log"
end

def csv_path
  File.join log_dir, "#{Card[:performance_log].codename}.csv"
end

def add_log_entry request, html_log
  time = DateTime.now.utc.strftime "%Y%m%d%H%M%S"
  name = "%s+%s %s" % [Card[:performance_log].name, time, request.gsub('/','&#47;') ]
  if Card.fetch name
    name += 'a'
    while Card.fetch name
      name.next!
    end
  end

  Card::Auth.as_bot do
    File.open(Card[:performance_log].log_path(name), 'w') {|f| f.puts html_log}
    Card[:performance_log].add_item! name
  end
end

def add_csv_entry page, wbench_data, runs
  if !File.exists? csv_path
    File.open(csv_path, 'w') { |f| f.puts "page,render time, dom loading time, connection time"}
  end
  browser = wbench_data.browser
  runs.times do |i|
    csv_data = [
      page,
      browser['responseEnd'][i] - browser['requestStart'][i],
      browser['domComplete'][i] - browser['domLoading'][i], # domLoadingTime
      browser['requestStart'][i],  # domLoadingStart
    ]
    csv_line = CSV.generate_line(csv_data)
    File.open(csv_path, 'a') { |f| f.puts csv_line }
  end
end

format :html do
  view :core do |args|
    wagn_data =
      card.item_names.map do |item|
        path = card.log_path item
        if File.exists? path
          File.read(path)
        end
      end.compact.join "\n"
    browser_data = CSV.parse(File.read(card.csv_path))
    output [
      table(browser_data, true),
      wagn_data
    ]
  end

  def table data, with_header=false
    thead = if with_header
              content_tag :thead do
                content_tag :tr do
                  data.shift.map do |item|
                    content_tag :th, item
                  end.join "\n"
                end
              end
            end
    tbody = content_tag :tbody do
              data.map do |row|
                content_tag :tr do
                  row.map do |item|
                    content_tag :td, item
                  end.join "\n"
                end
              end.join "\n"
            end

    %{
      <table class="table">
        #{thead}
        #{tbody}
      </table>
    }
  end
end

