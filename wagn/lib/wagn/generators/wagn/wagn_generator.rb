require 'rails/generators/app_base'


class WagnGenerator < Rails::Generators::AppBase

#class WagnGenerator < Rails::Generators::AppGenerator

  source_root File.expand_path('../templates', __FILE__)
  
  argument :deck_path, :required=>false

  class_option :database, :type => :string, :aliases => "-d", :default => "mysql",
    :desc => "Preconfigure for selected database (options: #{DATABASES.join('/')})"
    
  class_option 'core-dev', :type => :boolean, aliases: '-c', :default => false, :group => :runtime, 
    desc: "Prepare deck for wagn core testing"
    
  class_option 'gem-path', :type => :string, aliases: '-g', :default => false, :group => :runtime, 
    desc: "Path to local gem installation (Default, use env WAGN_GEM_PATH)"
    
  class_option 'mod-dev', :type => :boolean, aliases: '-m', :default => false, :group => :runtime, 
    desc: "Prepare deck for mod testing"
    
  class_option 'interactive', :type => :boolean, aliases: '-i', :default => false, :group => :runtime, 
    desc: "Prompt with dynamic installation options"
                        
  public_task :create_root
  
## should probably eventually use rails-like AppBuilder approach, but this is a first step.  
  def dev_setup
    # TODO: rename or split, gem_path points to the source repo, card and wagn gems are subdirs
    @gemfile_gem_path = @gem_path = options['gem-path']
    env_gem_path = ENV['WAGN_GEM_PATH']
    if env_gem_path.present?
      @gemfile_gem_path = %q{#{ENV['WAGN_GEM_PATH']}}
      @gem_path = env_gem_path
    end
    
    @include_jasmine_engine = false
    if options['core-dev']
      unless @gem_path
        @gemfile_gem_path = @gem_path = ask("Enter the path to your local wagn gem installation: ")
      end

      @include_jasmine_engine = true
      @spec_path = @gem_path
      @spec_helper_path = File.join @spec_path, 'card', 'spec', 'spec_helper'
      empty_directory 'spec'
      inside 'spec' do
        copy_file File.join('javascripts', 'support', 'wagn_jasmine.yml'), File.join('javascripts', 'support','jasmine.yml')
      end
      
      @features_path = File.join @gem_path, 'wagn/features/'  # ending slash is important in order to load support and step folders
      @simplecov_config = "card_core_dev_simplecov_filters"
    elsif options['mod-dev']
      @spec_path = 'mod/'
      @spec_helper_path = './spec/spec_helper'
      @simplecov_config = "card_simplecov_filters"
      empty_directory 'spec'
      inside 'spec' do
        template 'spec_helper.rb'
        copy_file File.join(  'javascripts', 'support', 'deck_jasmine.yml'), File.join('javascripts', 'support','jasmine.yml')
      end
    end
    
    if options['core-dev'] || options['mod-dev']
      template "rspec", ".rspec"
      template "simplecov", ".simplecov"
      empty_directory 'bin'
      inside 'bin' do
        template 'spring'
      end
    end
  end

  def rakefile
    template "Rakefile"
  end

#  def readme
#    copy_file "README", "README.rdoc"
#  end
  
  def mod
    empty_directory_with_gitkeep 'mod'
  end
  
  def log
    empty_directory_with_gitkeep 'log'
  end
  
  def files
    empty_directory_with_gitkeep 'files'
  end
  
  def tmp
    empty_directory 'tmp'
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
      template 'routes.erb', "routes.rb"
      template "environment.rb"
      template "boot.rb"
      template "databases/#{options[:database]}.yml", "database.yml"  
      if options['core-dev']
        template "cucumber.yml"
      end
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
    chmod "script", 0755 & ~File.umask, :verbose => false
  end
  
  public_task :run_bundle
  
  def seed_data
    if options['interactive']

      require File.join destination_root, 'config', 'application'  # need this for Rails.env
      menu_options = ActiveSupport::OrderedHash.new()
      
      database_seeded = proc do
        menu_options['x'][:desc] = "exit"
        menu_options['r'] = {
          :desc    => 'run wagn server',
          :command => 'wagn server',
          :code    => proc { system "cd #{destination_root} && wagn server" }
        }
      end
      
      menu_options['d'] = { 
          :desc    => 'edit database configuration file',
          :command => 'nano config/database.yml',
          :code    =>  proc { system "nano #{File.join destination_root, 'config', 'database.yml'}" }
        }
      menu_options['c'] =  { 
          :desc    => 'configure Wagn (e.g. email settings)',
          :command => 'nano config/application.rb',
          :code    =>  proc { system "nano #{File.join destination_root, 'config', 'application.rb'}" }
        }
      menu_options['s'] =  { 
          :desc    => "seed #{Rails.env}#{ " and test" if options['core-dev'] or options['mod-dev']} database",
          :command => 'wagn seed',
          :code    => proc do
            system("cd #{destination_root} && bundle exec rake wagn:seed") 
            if options['core-dev'] or options['mod-dev']
              system("cd #{destination_root} && RAILS_ENV=test bundle exec rake wagn:seed")  
            end
            database_seeded.call
          end
        }
      menu_options['a'] = { 
          :desc    => 'seed all databases (production, development, and test)',
          :command => 'wagn seed --all',
          :code    => proc do
            %w( production development test ).each do |env|
              system("cd #{destination_root} && RAILS_ENV=#{env} bundle exec rake wagn:seed")  
            end
            database_seeded.call
          end
        }
      menu_options['x'] =  { 
          :desc    => "exit (run 'wagn seed' to complete the installation later)" 
        }
      
      
      def build_menu options
        lines = ["What would you like to do next?"]
        lines += options.map do |key, v| 
          command = ' '*(65-v[:desc].size) + '[' + v[:command] + ']' if v[:command] 
          "  #{key} - #{v[:desc]}#{command if command}"
        end
        lines << "[#{options.keys.join}]"
        "\n#{lines.join("\n")}\n"
      end
      
      while  (answer = ask(build_menu(menu_options))) != 'x'      
        menu_options[answer][:code].call       
      end
      
    else
      puts "Review the database configuration in config/database.yml and run 'wagn seed' to complete the installation.\nStart the server with 'wagn server'."
    end
  end
  
  protected
  def self.banner
     "wagn new #{self.arguments.map(&:usage).join(' ')} [options]"
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
    ].find { |f| File.exist?(f) } unless RbConfig::CONFIG['host_os'] =~ /mswin|mingw/
  end
  
  ### the following is straight from rails and is focused on checking the validity of the app name.
  ### needs wagn-specific tuning
  
  
  def app_name
    @app_name ||= defined_app_const_base? ? defined_app_name : File.basename(destination_root)
  end

  def defined_app_name
    defined_app_const_base.underscore
  end

  def defined_app_const_base
    Rails.respond_to?(:application) && defined?(Rails::Application) &&
      Wagn.application.is_a?(Rails::Application) && Wagn.application.class.name.sub(/::Application$/, "")
  end

  alias :defined_app_const_base? :defined_app_const_base
  
  def app_const_base
    @app_const_base ||= defined_app_const_base || app_name.gsub(/\W/, '_').squeeze('_').camelize
  end
  alias :camelized :app_const_base
  
  def app_const
    @app_const ||= "#{app_const_base}::Application"
  end

  def valid_const?
    if app_const =~ /^\d/
      raise Error, "Invalid application name #{app_name}. Please give a name which does not start with numbers."
#    elsif RESERVED_NAMES.include?(app_name)
#      raise Error, "Invalid application name #{app_name}. Please give a name which does not match one of the reserved rails words."
    elsif Object.const_defined?(app_const_base)
      raise Error, "Invalid application name #{app_name}, constant #{app_const_base} is already in use. Please choose another application name."
    end
  end
end
