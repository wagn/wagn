# collect arrays of the form
# [task symbol, { execute_policy: block, stats_policy: block }]
basket :tasks

event :admin_tasks, :initialize, on: :update do
  return unless (task = Env.params[:task])
  raise Card::Error::PermissionDenied, self unless Auth.always_ok?
  case task.to_sym
  when :clear_cache          then Card::Cache.reset_all
  when :repair_references    then Card::Reference.repair_all
  when :repair_permissions   then Card.repair_all_permissions
  when :clear_solid_cache    then Card.clear_solid_cache
  when :clear_machine_cache  then Card.reset_all_machines
  else
    task_data = tasks.find { |h| h[:name].to_sym == task.to_sym }
    task_data[:execute_policy].call if task_data
  end
  abort :success
end

format :html do
  view :core do |_args|
    stats = card_stats
    stats += cache_stats
    stats += memory_stats
    card.tasks.each do |task|
      stats += Array.wrap task[:stats]
    end
    table_content = stats.map { |args| stat_row(args) }
    table table_content, header: %w(Stat Value Action)
  end

  def card_stats
    [
      { title: "cards",
        count: Card.where(trash: false) },
      { title: "actions",
        count: Card::Action,
        link_text: "delete old",
        task: "delete_old_revisions" },
      { title: "references",
        count: Card::Reference,
        link_text: "repair all",
        task: "repair_references" }
    ]
  end

  def cache_stats
    stats = [
      { title: "solid cache",
        count: solid_cache_count, unit: " cards",
        link_text: "clear solid cache",
        task: "clear_solid_cache" },
      { title: "machine cache",
        count: machine_cache_count, unit: " cards",
        link_text: "clear machine cache",
        task: "clear_machine_cache" }
    ]
    return stats unless Card.config.view_cache
    stats << { title: "view cache",
               count: Card::View,
               link_text: "clear view cache",
               task: "clear_view_cache" }
  end

  def memory_stats
    oldmem = session[:memory]
    session[:memory] = newmem = card.profile_memory
    stats = [
      { title: "memory now",
        count: newmem, unit: "M",
        link_text: "clear cache", task: "clear_cache" }
    ]
    return stats unless oldmem
    stats << { title: "memory prev", count: oldmem, unit: "M" }
    stats << { title: "memory diff", count: newmem - oldmem, unit: "M" }
    stats
  end

  def stat_row args={}
    res = [(args[:title] || "")]
    res << "#{count(args[:count])}#{args[:unit]}"
    return res unless args[:task]
    res << link_to_card(:admin, (args[:link_text] || args[:task]),
                        path: { action: :update, task: args[:task] })
    res
  end

  def count counter
    counter = counter.call if counter.is_a?(Proc)
    counter.respond_to?(:count) ? counter.count : counter
  end

  def solid_cache_count
    Card.search right: { codename: "solid_cache" }, return: "count"
  end

  def machine_cache_count
    Card.search right: { codename: "machine_cache" }, return: "count"
  end

  def delete_sessions_link months
    link_to_card :admin, months, path: { action: :update, months: months,
                                         task: "delete_old_sessions" }
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
