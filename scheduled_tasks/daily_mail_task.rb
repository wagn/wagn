class DailyMailTask < Scheduler::SchedulerTask
  environments :all
  # environments :staging, :production

  cron '0 0 * * *'

  def run
    Card::Observer.send_timer_mails :daily
    log("I've sent daily emails!")   # write to scheduler daemon log
  end
end