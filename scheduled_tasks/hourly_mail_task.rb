class HourlyMailTask < Scheduler::SchedulerTask
  environments :all
  # environments :staging, :production
  
  cron '0 * * * *'
  
  def run
    Card::Observer.send_timer_mails :hourly
    log("I've sent hourly emails!")   # write to scheduler daemon log
  end
end