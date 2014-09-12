class WeeklyMailTask < Scheduler::SchedulerTask
  environments :all
  # environments :staging, :production

  cron '0 0 * * 0'

  def run
    Card::Observer.send_timer_mails :weekly
    log("I've sent weekly emails!")   # write to scheduler daemon log
  end
end