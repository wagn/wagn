namespace :wagn do
  desc "create configuration files"
  task :install do
    require 'erb'
    rails_root = File.expand_path('./') # must be run from rails root dir
    # not using Rails.root because this task is putting core files in place and
    # therefore should not load rails environment
    
    config_dir = File.join(rails_root, 'config')
    sample_dir = File.join(rails_root, 'config/samples')
    
    #File.expand_path('../boot', __FILE__)
    @engine = ( ENV['ENGINE'] || 'mysql' ).to_sym
    @mode = ( ENV['MODE'] || 'default' ).to_sym

    cp File.join(sample_dir, "wagn.yml"), File.join(config_dir)
    
    if @mode==:dev
      cp File.join(sample_dir, "cucumber.yml"), File.join(config_dir)
    end      
    
    dbfile = File.read File.join(sample_dir, 'database.yml.erb')
    
    File.open File.join(config_dir, 'database.yml'), 'w' do |file|
      file.write ERB.new(dbfile).result(binding)
    end
    
    bundle_config = "BUNDLE_WITHOUT: "
    bundle_config << ( @engine==:mysql ? 'postgres' : 'mysql' )
    bundle_config << ":test:debug:development:assets\n" unless @mode==:dev

    File.open File.join(rails_root, '.bundle/config'), 'w' do |file|
      file.write bundle_config
      puts ""
    end
  end
end