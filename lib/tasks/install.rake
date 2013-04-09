namespace :wagn do
  desc "create a wagn database from scratch"
  task :create do
    puts "dropping"
    begin
      Rake::Task['db:drop'].invoke
    rescue
      puts "not dropped"
    end

    puts "creating"
    Rake::Task['db:create'].invoke

    puts "loading schema"
    Rake::Task['db:schema:load'].invoke

    if Rails.env == 'test'
      puts "loading test fixtures"
      Rake::Task['db:fixtures:load'].invoke
    else
      puts "loading bootstrap"
      Rake::Task['wagn:bootstrap:load'].invoke
    end
  end
  
  
  desc "install wagn configuration files"
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
  end

  desc "migrate content"
  task :migrate_content => :environment do
    rpaths = Rails.application.paths
    rpaths.add 'db/migrate_content'
    paths = ActiveRecord::Migrator.migrations_paths = rpaths['db/migrate_content'].to_a
    
    ActiveRecord::Base.table_name_suffix = '_content'
    ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
    ActiveRecord::Migrator.migrate paths, ENV["VERSION"] ? ENV["VERSION"].to_i : nil
  end

  desc "copy over .htaccess files useful in production mode"
  task :copy_htaccess do
    access_file = File.join(Rails.root, 'config/samples/asset_htaccess')

    %w{ files assets }.each do |dirname|
      dir = File.join Rails.public_path, dirname
      mkdir_p dir
      cp access_file, File.join( dir, '.htaccess' )
    end
  end

end
