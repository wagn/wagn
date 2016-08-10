
format :html do
  view :core do |_args|
    stats = [
      ["cards", Card.where(trash: false)],
      ["trashed cards", Card.where(trash: true),
       { link_text: "delete all", task: "empty_trash" }],
      ["actions", Card::Action,
       { link_text: "delete old", task: "delete_old_revisions" }],
      ["references", Card::Reference,
       { link_text: "repair all", task: "repair_references" }]
    ]
    stats += cache_stats
    stats += memory_stats
    table_content = stats.map { |args| stat_row(*args) }
    table table_content, header: %w(Stat Value Action)
  end

  def cache_stats
    stats = [
      ["solid cache", solid_cache_count,
       { unit: " cards", link_text: "clear cache",
         task: "clear_solid_cache" }],
      ["machine cache", machine_cache_count,
       { unit: " cards", link_text: "clear cache",
         task: "clear_machine_cache" }]
    ]
    return stats unless Card.config.view_cache
    stats <<
      ["view cache", Card::ViewCache,
       { link_text: "clear view cache", task: "clear_view_cache" }]
    stats
  end

  def memory_stats
    oldmem = session[:memory]
    session[:memory] = newmem = card.profile_memory
    stats = [
      ["memory now", newmem,
       { unit: "M", link_text: "clear cache", task: "clear_cache" }]
    ]
    return stats unless oldmem
    stats << ["memory prev", oldmem, { unit: "M" }]
    stats << ["memory diff", newmem - oldmem, { unit: "M" }]
    stats
  end

  def stat_row name, countable, args={}
    res = [name]
    count = countable.respond_to?(:count) ? countable.count : countable
    res << "#{count}#{args[:unit]}"
    return res unless args[:task]
    path = card_path("update/:all?task=#{args[:task]}")
    res << link_to(args[:link_text] || args[:task], path)
    res
  end

  def solid_cache_count
    Card.search right: { codename: "solid_cache" }, return: "count"
  end

  def machine_cache_count
    Card.search right: { codename: "machine_cache" }, return: "count"
  end

  def delete_sessions_link months
    link_to months,
            card_path("update/:all?task=delete_old_sessions&months=#{months}")
  end
end

def current_memory_usage
  `ps -o rss= -p #{Process.pid}`.to_i
end

def profile_memory &block
  before = current_memory_usage
  _file, _line, = caller[0].split(":")
  if block_given?
    instance_eval(&block)
  else
    before = 0
  end
  (current_memory_usage - before) / 1024.to_i
end
