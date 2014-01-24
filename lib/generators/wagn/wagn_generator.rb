require 'rails/generators/app_base'

class WagnGenerator < Rails::Generators::AppBase
  source_root File.expand_path('../templates', __FILE__)
  
  public_task :create_root
  
## should probably eventually use rails-like AppBuilder approach, but this is a first step.  
  
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
    directory 'config' #almost certainly want to improve this!
  end
  
  def script
    directory "script" do |content|
      "#{shebang}\n" + content
    end
    chmod "script", 0755 & ~File.umask, :verbose => false
  end
  
  protected
  
  
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
      Rails.application.is_a?(Rails::Application) && Rails.application.class.name.sub(/::Application$/, "")
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
