# -*- encoding : utf-8 -*-
Wagn.application.class.configure do
  # Settings specified here will take precedence over those in config/application.rb

  config.eager_load = false

  # The test environment is used exclusively to run your application's
  # test suite.  You never need to work with it otherwise.  Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs.  Don't rely on the data there!
  config.cache_classes = true

  config.assets.enabled = true if Object.const_defined?(:JasmineRails)

  # Configure static asset server for tests with Cache-Control for performance
  config.serve_static_files = true
  config.static_cache_control = "public, max-age=3600"

  # Log error messages when you accidentally call methods on nil
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test
  config.action_mailer.perform_deliveries = true
  config.action_mailer.default charset: "utf-8"

  # config.action_mailer.delivery_method = :smtp
  # config.action_mailer.smtp_settings = { address: "localhost", port: 1025 }

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # FIXME: - add back the next one when we go back to 3.2
  # Raise exception on mass assignment protection for Active Record models
  #  config.active_record.mass_assignment_sanitizer = :strict

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr

  config.active_job.queue_adapter = :delayed_job
  # Note: With delay_jobs set to false integrate_with_delay events don't run
  # in a separate process and hence can behave differently from a real
  # environment. To test integrate_with_delay events properly set delay_jobs to
  # true in your test
  Delayed::Worker.delay_jobs = false

  config.active_record.raise_in_transactional_callbacks = true

  # Use Pry instead of IRB
  silence_warnings do
    begin
      require "pry"
      IRB = Pry
    rescue LoadError
    end
  end
end
