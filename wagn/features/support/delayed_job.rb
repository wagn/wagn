Before("@delayed-jobs") do
  Delayed::Worker.delay_jobs = true
end

After("@delayed-jobs") do
  Delayed::Worker.delay_jobs = false
end

Before("@background-jobs") do
  Delayed::Worker.delay_jobs = true
  system "env RAILS_ENV=cucumber rake jobs:work &"
end

After("@background-jobs") do
  Delayed::Worker.delay_jobs = false
  system "ps -ef | grep 'rake jobs:work' | grep -v grep | awk '{print $2}' | "\
         "xargs kill -9"
end
