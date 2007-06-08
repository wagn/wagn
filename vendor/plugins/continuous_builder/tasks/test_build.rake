desc "Pull latest revision, run unit and functional tests, send email on errors"
task :test_latest_revision => :environment do
  require(File.dirname(__FILE__) + "/../lib/continuous_builder")

  build = ContinuousBuilder::Build.new(
    :task_name        => ENV['RAKE_TASK'] || '',
    :bin_path         => ENV['BIN_PATH']  || "/usr/local/bin/",
    :application_root => RAILS_ROOT
  )

  notice_options = {
    :application_name => ENV['NAME'], 
    :recipients       => ENV['RECIPIENTS'], 
    :sender           => ENV['SENDER'] || "'Continuous Builder' <cb@example.com>" 
  }

  case build.run
    when :failed
      ContinuousBuilder::Notifier.deliver_failure(build, notice_options)
    when :revived
      ContinuousBuilder::Notifier.deliver_revival(build, notice_options)
    when :broken
      ContinuousBuilder::Notifier.deliver_broken(build, notice_options)
    when :unchanged, :succesful
      # Smile, be happy, it's all good
  end 
end