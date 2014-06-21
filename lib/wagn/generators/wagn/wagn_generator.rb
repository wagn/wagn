require 'rails/generators/app_base'


class WagnGenerator < Rails::Generators::AppBase

#class WagnGenerator < Rails::Generators::AppGenerator

  

  source_root File.expand_path('../templates', __FILE__)
  
  class_option :database, :type => :string, :aliases => "-d", :default => "mysql",
    :desc => "Preconfigure for selected database (options: #{DATABASES.join('/')})"
    
  class_option 'core-dev', :type => :boolean, aliases: '-c', :default => false, :group => :runtime, 
    desc: "Prepare deck for wagn core testing"
    
  class_option 'mod-dev', :type => :boolean, aliases: '-m', :default => false, :group => :runtime, 
    desc: "Prepare deck for mod testing"
    
  class_option 'interactive', :type => :boolean, aliases: '-i', :default => false, :group => :runtime, 
      desc: "Prompt with dynamic installation options"
                        
  public_task :create_root
  
## should probably eventually use rails-like AppBuilder approach, but this is a first step.  
  def core_dev_setup  
    if options['core-dev']
      @wagn_path = ask "Enter the path to your local wagn installation: "
      #@wagndev_path = ask "Please enter the path to your local wagn-dev installation (leave empty to use the wagn-dev gem): "
      @spec_path = File.join @wagn_path, 'spec'
      @spec_helper_path = File.join @spec_path, 'spec_helper'
      @features_path = File.join @wagn_path, 'features/'  # ending slash is important in order to load support and step folders
      
      template "rspec", ".rspec"
    elsif options['mod-dev']
      @spec_path = 'mods/'
      @spec_helper_path = 'wagn/mods_spec_helper'
      template "rspec", ".rspec"
    end
  end

  
  def rakefile
    template "Rakefile"
  end

#  def readme
#    copy_file "README", "README.rdoc"
#  end
  
  def mods
    empty_directory_with_gitkeep 'mods'
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
      seeded = false
      require File.join destination_root, 'config', 'application'  # need this for Rails.env
      while  (answer = ask( <<-TEXT
        
What would you like to do next?
  e - edit database configuration file (config/database.yml)
  s - seed #{Rails.env}#{ " and test" if options['core-dev'] or options['mod-dev']} database
  a - seed all databases (production, development, and test)
  x - exit #{ seeded ? "\n  r - run wagn server" : "(run 'wagn seed' to complete the installation later)"}
[esax#{'r' if seeded}]
TEXT
)) != 'x'      
        case answer
        when 'e'
          system "nano #{File.join destination_root, 'config', 'database.yml'}"
        when 's'
          require 'wagn/migration_helper'
          require 'rake'
          Wagn::Application.load_tasks
          Rake::Task['wagn:create'].invoke
          if options['core-dev'] or options['mod-dev']
            ENV['RELOAD_TEST_DATA'] = 'true'
            Rake::Task['db:test:prepare'].invoke
          end
          seeded = true
        when 'a'
          %w( production development test ).each do |env|
            system("cd #{destination_root} && RAILS_ENV=#{env} rake wagn:create")  
            # tried to set rails environment and invoke the task three times but it was only execute once, so I'm using 'system'
          end
          seeded = true
        when 'r'
          if seeded
            system "cd #{destination_root} && wagn server"
          else
            puts "You have to seed the database first before you can start the server."
          end
        end
      end
    else
      puts "Review the database configuration in config/database.yml and run 'wagn seed' to complete the installation.\nStart the server with 'wagn s'."
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
