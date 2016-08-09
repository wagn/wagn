require "rails/generators/app_base"

class WagnGenerator < Rails::Generators::AppBase
  # class WagnGenerator < Rails::Generators::AppGenerator

  source_root File.expand_path("../templates", __FILE__)

  argument :deck_path, required: false

  class_option :database,
               type: :string, aliases: "-d", default: "mysql",
               desc: "Preconfigure for selected database " \
                     "(options: #{DATABASES.join('/')})"

  class_option "core-dev",
               type: :boolean, aliases: "-c", default: false, group: :runtime,
               desc: "Prepare deck for wagn core testing"

  class_option "gem-path",
               type: :string, aliases: "-g", default: false, group: :runtime,
               desc: "Path to local gem installation " \
                     "(Default, use env WAGN_GEM_PATH)"

  class_option "mod-dev",
               type: :boolean, aliases: "-m", default: false, group: :runtime,
               desc: "Prepare deck for mod testing"

  class_option "interactive",
               type: :boolean, aliases: "-i", default: false, group: :runtime,
               desc: "Prompt with dynamic installation options"

  public_task :set_default_accessors!
  public_task :create_root

  ## should probably eventually use rails-like AppBuilder approach,
  # but this is a first step.
  def dev_setup
    # TODO: rename or split, gem_path points to the source repo,
    # card and wagn gems are subdirs
    @gemfile_gem_path = @gem_path = options["gem-path"]
    env_gem_path = ENV["WAGN_GEM_PATH"]
    if env_gem_path.present?
      @gemfile_gem_path = %q(#{ENV['WAGN_GEM_PATH']})
      @gem_path = env_gem_path
    end

    @include_jasmine_engine = false
    if options["core-dev"]
      core_dev_setup
      shared_dev_setup
    elsif options["mod-dev"]
      mod_dev_setup
      shared_dev_setup
    end
  end

  def rakefile
    template "Rakefile"
  end

  #  def readme
  #    copy_file "README", "README.rdoc"
  #  end

  def mod
    empty_directory_with_keep_file "mod"
  end

  def log
    empty_directory_with_keep_file "log"
  end

  def files
    empty_directory_with_keep_file "files"
  end

  def tmp
    empty_directory "tmp"
  end

  def gemfile
    template "Gemfile"
  end

  def configru
    template "config.ru"
  end

  def gitignore
    copy_file "gitignore", ".gitignore"
  end

  def config
    empty_directory "config"

    inside "config" do
      template "application.rb"
      template "routes.erb", "routes.rb"
      template "environment.rb"
      template "boot.rb"
      template "databases/#{options[:database]}.yml", "database.yml"
      template "cucumber.yml" if options["core-dev"]
    end
  end

  def public
    empty_directory "public"

    inside "public" do
      template "robots.txt"
      empty_directory "files"

      inside "files" do
        template "htaccess", ".htaccess"
      end
    end
  end

  def script
    directory "script" do |content|
      "#{shebang}\n" + content
    end
    chmod "script", 0755 & ~File.umask, verbose: false
  end

  public_task :run_bundle

  def seed_data
    if options["interactive"]
      Interactive.new(options, destination_root).run
    else
      puts "Now:
1. Run `wagn seed` to seed your database (see db configuration in config/database.yml).
2. Run `wagn server` to start your server"
    end
  end

  def database_gemfile_entry
    return [] if options[:skip_active_record]
    gem_name, gem_version = gem_for_database
    if gem_name == "mysql2"
      # && Gem.loaded_specs['rails'].version < Gem::Version.new('4.2.5')
      # Rails update from 4.2.4 to 4.2.5 didn't help.
      # Current mysql2 gem (0.4.1) is still causing trouble.
      # Maybe with the next Rails release?
      # Could also be that ruby 1.9.3 is the problem.
      gem_version = "0.3.20"
    end
    msg = "Use #{options[:database]} as the database for Active Record"
    GemfileEntry.version gem_name, gem_version, msg
  end

  def self.banner
    "wagn new #{arguments.map(&:usage).join(' ')} [options]"
  end

  protected

  def core_dev_setup
    unless @gem_path
      @gemfile_gem_path =
        @gem_path = ask("Enter the path to your local wagn gem installation: ")
    end

    @include_jasmine_engine = true
    @spec_path = @gem_path
    @spec_helper_path = File.join @spec_path, "card", "spec", "spec_helper"
    empty_directory "spec"

    @cardio_gem_root = File.join @gem_path, "card"
    @wagn_gem_root = File.join @gem_path, "wagn"
    inside "spec" do
      template File.join("javascripts", "support", "wagn_jasmine.yml"),
                File.join("javascripts", "support", "jasmine.yml")
    end

    # ending slash is important in order to load support and step folders
    @features_path = File.join @gem_path, "wagn/features/"

    @simplecov_config = "card_core_dev_simplecov_filters"
  end

  def mod_dev_setup
    @spec_path = "mod/"
    @spec_helper_path = "./spec/spec_helper"
    @simplecov_config = "card_simplecov_filters"
    empty_directory "spec"
    inside "spec" do
      template "spec_helper.rb"
      template File.join("javascripts", "support", "deck_jasmine.yml"),
                File.join("javascripts", "support", "jasmine.yml")
    end
  end

  def shared_dev_setup
    template "rspec", ".rspec"
    template "simplecov", ".simplecov"
    empty_directory "bin"
    inside "bin" do
      template "spring"
    end
  end

  def mysql_socket
    @mysql_socket ||= [
      "/tmp/mysql.sock",                        # default
      "/var/run/mysqld/mysqld.sock",            # debian/gentoo
      "/var/tmp/mysql.sock",                    # freebsd
      "/var/lib/mysql/mysql.sock",              # fedora
      "/opt/local/lib/mysql/mysql.sock",        # fedora
      "/opt/local/var/run/mysqld/mysqld.sock",  # mac + darwinports + mysql
      "/opt/local/var/run/mysql4/mysqld.sock",  # mac + darwinports + mysql4
      "/opt/local/var/run/mysql5/mysqld.sock",  # mac + darwinports + mysql5
      "/opt/lampp/var/mysql/mysql.sock"         # xampp for linux
    ].find { |f| File.exist?(f) } unless RbConfig::CONFIG["host_os"] =~ /mswin|mingw/
  end

  ### the following is straight from rails and is focused on checking
  # the validity of the app name.needs wagn-specific tuning

  def app_name
    @app_name ||= if defined_app_const_base?
                    defined_app_name
                  else
                    File.basename(destination_root)
                  end
  end

  def defined_app_name
    defined_app_const_base.underscore
  end

  def defined_app_const_base
    Rails.respond_to?(:application) && defined?(Rails::Application) &&
      Wagn.application.is_a?(Rails::Application) &&
      Wagn.application.class.name.sub(/::Application$/, "")
  end

  alias defined_app_const_base? defined_app_const_base

  def app_const_base
    @app_const_base ||= defined_app_const_base ||
                        app_name.gsub(/\W/, "_").squeeze("_").camelize
  end
  alias camelized app_const_base

  def app_const
    @app_const ||= "#{app_const_base}::Application"
  end

  def valid_const?
    if app_const =~ /^\d/
      raise Error, "Invalid application name #{app_name}. " \
                   "Please give a name which does not start with numbers."
    #    elsif RESERVED_NAMES.include?(app_name)
    #      raise Error, "Invalid application name #{app_name}." \
    # "Please give a name which does not match one of the reserved rails words."
    elsif Object.const_defined?(app_const_base)
      raise Error, "Invalid application name #{app_name}, " \
                   "constant #{app_const_base} is already in use. " \
                   "Please choose another application name."
    end
  end
end
