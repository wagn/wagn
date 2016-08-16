

Decko::Engine.configure do
  config.cache_classes = false
end

# -*- encoding : utf-8 -*-

Wagn.application.class.configure do
  # Settings specified here will take precedence over those in config/application.rb

  config.eager_load = false

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false
  config.reload_classes_only_on_change = false

  if defined?(RailsDevTweaks)
    config.dev_tweaks.autoload_rules do
      skip "/files"
      skip /view\=status/
    end
  end

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # See everything in the log (default is :info)
  config.log_level = :debug

  config.active_record.raise_in_transactional_callbacks = true

  # config.performance_logger = {
  #     methods:   [:event, :search, :fetch, :view],  # choose methods to log
  #     min_time:  100,                              # show only method calls that are slower than 100ms
  #     max_depth: 3,                               # show nested method calls only up to depth 3
  #     details:   true                                # show method arguments and sql
  #     log_level: :info
  # }

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  # config.assets.compress = false
  #
  #   # Expands the lines which load the assets
  #   config.assets.debug = false
  #
  #   # This needs to be on for tinymce to work, because several important files (themes, etc) are only served statically
  #   config.serve_static_files = ENV['STATIC_ASSETS'] || true
  #
  #   # Setting a bogus directory so rails won't find public/assets in dev mode.
  #   # Normally you could skip that by not serving static assets, but that breaks tinymce (see above)
  #   config.assets.prefix = "dynamic-assets"

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  #  config.active_record.auto_explain_threshold_in_seconds = 0.5

  #  if File.exists?(File.join(Rails.root,'tmp', 'debug.txt'))
  #    require 'ruby-debug'
  #    Debugger.wait_connection = true
  #    Debugger.start_remote
  #    File.delete(File.join(Rails.root,'tmp', 'debug.txt'))
  #  end

  config.action_mailer.perform_deliveries = false

  # Use Pry instead of IRB
  silence_warnings do
    begin
      require "pry"
      IRB = Pry
    rescue LoadError
    end
  end
end

# Paperclip.options[:command_path] = "/opt/local/bin"
