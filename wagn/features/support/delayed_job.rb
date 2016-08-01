Before('@delay-jobs') do
  Delayed::Worker.delay_jobs = true
end

After('@delay-jobs') do
  Delayed::Worker.delay_jobs = false
end

Before('@background-jobs') do
  system 'env RAILS_ENV=cucumber rake jobs:work &'
end

After('@background-jobs') do
  system "ps -ef | grep 'rake jobs:work' | grep -v grep | awk '{print $2}' | "\
         'xargs kill -9'
end
