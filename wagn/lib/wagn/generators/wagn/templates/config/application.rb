require File.expand_path('../boot', __FILE__)

require 'wagn/application'

module <%= app_const_base %>
  class Application < Wagn::Application
    config.performance_logger = nil

    # Wagn inherits Rails configuration options.  See http://guides.rubyonrails.org/configuring.html

    # Email configuration
    config.action_mailer.perform_deliveries = false
    # config.action_mailer.delivery_method  = ...
    # config.action_mailer.smtp_settings    = ...

    # Example configuration for mailcatcher, a simple smtp server.
    # See http://mailcatcher.me for more information
    # config.action_mailer.delivery_method = :smtp
    # config.action_mailer.smtp_settings = { address: "localhost", port: 1025 }


    # Delayed jobs
    # Moves time-consuming minor tasks that are part of a card update
    # (like sending notifications to followers) to a background process.
    # To activate it add the gems 'delayed_job_active_record' and 'daemons'
    # to the Gemfile, uncomment the two lines below and run
    # 'RAILS_ENV=production script/delayed_job start' to start the background process.
    # See https://github.com/collectiveidea/delayed_job#running-jobs for more information
    #
    # config.active_job.queue_adapter = :delayed_job
    # Delayed::Worker.delay_jobs = true

    # The below keys are fine for testing but should not be used in production sites.

    # config.read_only = true
    # defaults to false
    # disallows creating, updating, and deleting cards.

    # config.cache_store = :file_store, 'tmp/cache'
    # determines caching mechanism.  options include: file_store, memory_store, mem_cache_store, dalli_store...
    #
    # for production, we highly recommend memcache
    # here's a sample configuration for use with the dalli gem
    # config.cache_store = :dalli_store, []

    # config.paths['files'] = 'files'
    # where uploaded files are actually stored. (eg Image and File cards)

    # config.file_storage = :protected
    # File storage options (see http://wagn.org/file_storage_options)
    # options include: protected, unprotected, cloud, web, coded
    # defaults to protected
    # config.file_default_bucket = :my_bucket
    # config.file_buckets = {
    #   my_bucket: {
    #     provider: "fog/aws",
    #     directory: "bucket-name",
    #     subdirectory: "files",
    #     credentials: {
    #        provider: 'AWS'                         # required
    #        aws_access_key_id: 'key'                # required
    #        aws_secret_access_key: 'secret-key'     # required
    #        region: 'eu-central-1'                  # optional, defaults to 'us-east-1'
    #        host: 's3.example.com'                  # optional, defaults to nil
    #        endpoint: 'https://s3.example.com:8080' # optional, defaults to nil
    #     }
    #     attributes: { "Cache-Control" => "max-age=#{365.day.to_i}" },
    #     public: true,
    #     authenticated_url_expiration: 180  # if public is set to false this
    #                                        # option is needed
    #   }
}

    # config.paths['mod'] << 'my-mod-dir'
    # add a new directory for code customizations, or "mods"

    # config.allow_inline_styles = false
    # don't strip style attributes (not recommended)

    # config.override_host = nil
    # don't autodetect host (example.com) from web requests

    # config.override_protocol = nil
    # don't autodetect protocol (http/https) from web requests
  end
end
