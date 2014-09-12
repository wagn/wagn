class MonthlyMailTask < Scheduler::SchedulerTask
  environments :all
  # environments :staging, :production

  cron '0 0 1 * *'

  def run
    Card::Observer.send_timer_mails :monthly
    log("I've sent monthly emails!")   # write to scheduler daemon log
  end
end