class Card::Log::Performance::CategoryLog
  HIERARCHY = {
      'SQL'  => 0,
      'rule' => 1,
      'fetch' => 2,
      'content' => 3,
      'format'  => 4
    }

  def initialize category=nil
    @time_per_category = Hash.new { |h, key| h[key] = 0 }
    @start_time = {}
    @stack = []
    if category
      start category
    end
  end

  def start category
    if active_category
      if hierarchy(category) < hierarchy(active_category)
        pause active_category
      else
        return
      end
    end
    @start_time[category] = Time.now
    @stack << category

  end

  def stop category
    if active_category == category
      save_duration category
      @stack.pop
      if active_category
        continue active_category
      end
    end
  end

  def duration category
    @time_per_category[category]
  end

  def each_pair
    cats = (['SQL', 'rule', 'fetch', 'content', 'format'] & @time_per_category.keys) |  @time_per_category.keys
    cats.each do |key|
      yield(key, @time_per_category[key])
    end
  end

  private

  def active_category
    @stack.last
  end

  def pause category
    save_duration category
  end

  def continue category
    @start_time[category] = Time.now
  end

  def hierarchy category
    HIERARCHY[category] || -1
  end

  def save_duration category
    @time_per_category[category] += (Time.now - @start_time[category]) * 1000
  end

end