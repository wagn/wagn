source 'http://rubygems.org'
#source "http://gems.github.com"

gemspec

gem 'wagn', :path=>File.expand_path( '../', __FILE__ )

gem 'wagn-dev', :path=>File.expand_path( '../../wagn-dev', __FILE__ ), :group=>:development
gem "mysql2", "~> 0.3"


#note: handling of pretty much all of the below should be moved to wagn-dev
group :assets do
  gem 'coffee-rails', "~> 3.1"                 # pretty code; compiles to JS
  gem 'uglifier'                               # makes pretty code ugly again.  compresses js/css for fast loading

  gem 'jquery-rails',  '~> 3.1'                # main js framework, along with rails-specific unobtrusive lib
  gem 'jquery-ui-rails',  '~> 4.2'
  gem "jquery_mobile_rails", "~> 1.4.1"
  
  gem 'tinymce-rails', '~> 3.4'                # wysiwyg editor
  
  # execjs is necessary for developing coffeescript.  mac users have execjs built-in; don't need this one
  gem 'therubyrhino', :platform=>:ruby         # :ruby is MRI rubies, so if you use a mac ruby ...
end



group :test do
  
  
  gem 'simplecov', '~> 0.7.1', :require => false  #test coverage
    
  # SPECS see spec dir
  gem 'rspec-rails', "~> 2.6"                  # behavior-driven-development suite
  
  gem 'guard-rspec', '~> 4.2'                  # trigger test runs based on file edits
  if RUBY_PLATFORM =~ /darwin/
    gem 'terminal-notifier-guard', '~> 1.5'    # use growler notifications on macs
  end
  
  # CUKES see features dir
  gem 'cucumber-rails', '~> 1.3', :require=>false # feature-driven-development suite
  gem 'capybara', '~> 2.2.1'                     # note, selectors were breaking when we used 2.0.1
  gem 'selenium-webdriver', '~> 2.39'
#  gem 'capybara-webkit'
  gem 'launchy'                                # lets cucumber launch browser windows

  gem 'timecop', '=0.3.5'                      # not clear on use/need.  referred to in shared_data.rb 
  # NOTE: had weird errors with timecop 0.4.4.  would like to update when possible
  
  gem 'spork', '>=0.9'
                                               
  gem 'rr'#, '=1.0.0'

  gem 'email_spec'                             # 
  gem 'database_cleaner', '~> 0.7'             # used by cucumber for db transactions
  
  gem 'turn', "~>0.8.3", :require => false      # Pretty printed test output.  (version constraint is to avoid minitest requirement)
  gem 'minitest', "~>4.0"
  
  
  
  #windows stuff
  gem 'win32console', '~> 1.3', :platforms => ['mingw', 'mswin']
  gem 'win32-process', '~> 0.6', :platforms => ['mingw', 'mswin']
end

gem 'ruby-prof', '~>0.12.1', :group=>:profile  # profiling

group :debug do
  gem 'byebug' if RUBY_VERSION =~ /^2/
  gem 'debugger'
end



