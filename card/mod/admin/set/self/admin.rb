event :admin_tasks, :initialize, on: :update do
  return unless (task = Env.params[:task])
  raise Card::Error::PermissionDenied.new(self) unless Auth.always_ok?

  case task.to_sym
  when :clear_cache          then Card::Cache.reset_all
  when :repair_references    then Card::Reference.repair_all
  when :empty_trash          then Card.empty_trash
  when :clear_view_cache     then Card::Cache::ViewCache.reset
  when :delete_old_revisions then Card::Action.delete_old
  when :repair_permissions   then Card.repair_all_permissions
  when :clear_solid_cache    then Card.clear_solid_cache
  when :clear_machine_cache  then Card.reset_all_machines
  end
  abort :success
end

format :html do
  view :core do |_args|
    stats = card_stats
    stats += cache_stats
    stats += memory_stats
    table_content = stats.map { |args| stat_row(*args) }
    table table_content, header: %w(Stat Value Action)
  end

  def card_stats
    [
      ["cards",         { count: Card.where(trash: false) }],
      ["trashed cards", { count: Card.where(trash: true),
                          link_text: "delete all", task: "empty_trash" }],
      ["actions",       { count: Card::Action,
                          link_text: "delete old",
                          task: "delete_old_revisions" }],
      ["references",    { count: Card::Reference,
                          link_text: "repair all", task: "repair_references" }]
    ]
  end

  def cache_stats
    stats = [
      ["solid cache", { count: solid_cache_count, unit: " cards",
                        link_text: "clear cache",
                        task: "clear_solid_cache" }],
      ["machine cache", { count: machine_cache_count, unit: " cards",
                          link_text: "clear cache",
                          task: "clear_machine_cache" }]
    ]
    return stats unless Card.config.view_cache
    stats <<
      ["view cache", { count: Card::Cache::ViewCache,
                       link_text: "clear view cache",
                       task: "clear_view_cache" }]
    stats
  end

  def memory_stats
    oldmem = session[:memory]
    session[:memory] = newmem = card.profile_memory
    stats = [
      ["memory now", { count: newmem, unit: "M",
                       link_text: "clear cache", task: "clear_cache" }]
    ]
    return stats unless oldmem
    stats << ["memory prev", { count: oldmem, unit: "M" }]
    stats << ["memory diff", { count: newmem - oldmem, unit: "M" }]
    stats
  end

  def stat_row name, args={}
    res = [name]
    args[:count] = args[:count].count if args[:count].respond_to?(:count)
    res << "#{args[:count]}#{args[:unit]}"
    return res unless args[:task]
    path = card_path("update/:admin?task=#{args[:task]}")
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
            card_path("update/:admin?task=delete_old_sessions&months=#{months}")
  end
end

def current_memory_usage
  `ps -o rss= -p #{Process.pid}`.to_i
end

def profile_memory &block
  before = current_memory_usage
  if block_given?
    instance_eval(&block)
  else
    before = 0
  end
  (current_memory_usage - before) / 1024.to_i
end
