require 'rubygems'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'
#require 'lib/wagn'
#require 'lib/wagn/version'

PKG_NAME = 'wagn'
PKG_VERSION = Wagn::Version.to_s
PKG_FILE_NAME = "#{PKG_NAME}-#{PKG_VERSION}"
RUBY_FORGE_PROJECT = 'wagon'
RUBY_FORGE_USER = 'lhoffman'

RELEASE_NAME  = PKG_VERSION
RUBY_FORGE_GROUPID = '1562'
RUBY_FORGE_PACKAGEID = ''

RDOC_TITLE = "Wagn -- Organic Knowledge Management"
RDOC_EXTRAS = ["README", "CHANGELOG", "LICENSE"]


namespace 'wagn' do
  spec = Gem::Specification.new do |s|
    s.name = PKG_NAME
    s.version = PKG_VERSION
    s.summary = 'An elegant and innovative tool for managing structured data.'
    s.description = "Wagn is an innovative tool for gathering and structuring\nknowledge that is at once easy to use and very powerful.\nIt brings the wiki spirit to structured data-- making it\naccessible, organic, and evolvable."
    s.homepage = 'http://wagn.org'
    s.rubyforge_project = RUBY_FORGE_PROJECT
    s.platform = Gem::Platform::RUBY
    s.requirements << 'rails'
    s.add_dependency 'rails',     '= 1.2.2'
    s.bindir = 'bin'
    s.executables = (Dir['bin/*'] + Dir['scripts/*']).map { |file| File.basename(file) } 
    s.require_path = 'lib'
    s.autorequire = 'wagn'
    s.has_rdoc = true
    s.rdoc_options << '--title' << RDOC_TITLE << '--line-numbers' << '--main' << 'README'
    s.extra_rdoc_files = RDOC_EXTRAS
    files = FileList['**/*']
    files.include 'public/.htaccess'
    files.exclude '**/._*'
    files.exclude '**/*.rej'
    files.exclude 'cache/*'
    files.exclude 'config/wagn.rb'
    files.exclude 'config/database.yml'
    files.exclude 'db/*.sql*.db'
    files.exclude 'doc'
    files.exclude 'log/*'
    files.exclude 'pkg'
    files.exclude 'tmp'  
    files.exclude 'snvlog.xml'
    #files.exclude 'vendor'            
    
    files.exclude 'selenium-on-rails'
    
    # if you include the test, it runs them.  that will be a good thing later, but for now
    # I want a tight debug loop on building the package.
    #files.exclude 'test'
    s.files = files.to_a
  end

  Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_zip = true
    pkg.need_tar = true
  end

  desc "Uninstall Gem"
  task :uninstall_gem do
    sh "gem uninstall #{PKG_NAME}" rescue nil
  end

  desc "Build and install Gem from source"
  task :install_gem => [:package, :uninstall_gem] do
    dir = File.join(File.dirname(__FILE__), 'pkg')
    chdir(dir) do
      latest = Dir["#{PKG_NAME}-*.gem"].last
      sh "gem install #{latest}"
    end
  end

  # task from Tobias Luetke's library 'liquid'
  desc "Publish the release files to RubyForge."
  task :release => [:gem, :package] do
    #files = ["gem", "tgz", "zip"].map { |ext| "pkg/#{PKG_FILE_NAME}.#{ext}" }

    #system("rubyforge login --username #{RUBY_FORGE_USER}")
  
    #files.each do |file|
    #  system("rubyforge add_release #{RUBY_FORGE_GROUPID} #{RUBY_FORGE_PACKAGEID} \"#{RELEASE_NAME}\" #{file}")
    #end
  end

  task :setup do
    sh "cd config; cp sample_database.yml database.yml; cp sample_wagn.rb wagn.rb; cd ../;"
  end   

  # before running this task, do a svn log --xml -rXXXX:XXX > svnlog.xml to get the log entries into
  # a log.xml file in current directory.  
  # 
  #  to get the right revision number, go into the directory of the last tag, do 
  # svn log --stop-on-copy   and see which version number has the comment of tagging the branch
  #
  task :format_changelog do 
    require 'rexml/document'
    filename = "svnlog.xml"
    elems = []
    REXML::Document.new(File.new(filename)).elements.each("//logentry") { |l|
      elems << "* #{l.elements['msg'].children[0]}"
    }
    puts elems.reverse.join("\n")
  end

end