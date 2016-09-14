class SpecLoader
  class << self
    def init
      require "spork"
      ENV["RAILS_ENV"] = "test"
      require "timecop"
    end

    def load_shared_examples
      Card::Mod::Loader.mod_dirs.each "spec/shared_examples" do |shared_ex_dir|
        Dir["#{shared_ex_dir}/**/*.rb"].sort.each { |f| require f }
      end
    end

    def prefork
      Spork.prefork do
        if ENV["RAILS_ROOT"]
          require File.join(ENV["RAILS_ROOT"], "/config/environment")
        else
          require File.expand_path("../../config/environment", __FILE__)
        end
        load_shared_examples

        yield if block_given?
      end
    end

    def rspec_config
      require "rspec/rails"

      # Requires supporting ruby files with custom matchers and macros, etc,
      # in spec/support/ and its subdirectories.
      #  Dir[File.join(Cardio.gem_root, "spec/support/**/*.rb")].each do |f|
      #    require f
      #  end

      RSpec.configure do |config|
        config.include RSpec::Rails::Matchers::RoutingMatchers,
                       file_path: %r{\bspec/controllers/}
        config.include RSpecHtmlMatchers
        # format_index = ARGV.find_index {|arg| arg =~ /--format|-f/ }
        # formatter = format_index ? ARGV[ format_index + 1 ] : 'documentation'
        # config.default_formatter=formatter

        config.infer_spec_type_from_file_location!
        # config.include CustomMatchers
        # config.include ControllerMacros, type: :controllers

        # == Mock Framework
        # If you prefer to mock with mocha, flexmock or RR,
        # uncomment the appropriate symbol:
        # :mocha, :flexmock, :rr

        config.use_transactional_fixtures = true
        config.use_instantiated_fixtures  = false

        config.before(:each) do
          Delayed::Worker.delay_jobs = false
          Card::Auth.current_id = JOE_USER_ID
          Card::Cache.restore
          Card::Env.reset
        end

        config.after(:each) do
          Timecop.return
        end
        yield config if block_given?
      end
    end

    def card_helper
      require File.expand_path "../card_spec_helper.rb", __FILE__
      RSpec::Core::ExampleGroup.send :include, Card::SpecHelper
      card_include = proc do
        Card.send :include, Card::SpecHelper::CardHelper
        Card.send :extend, Card::SpecHelper::CardHelper::ClassMethods
      end
      card_include.call
    end
  end
end
