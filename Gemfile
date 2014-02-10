source 'http://rubygems.org'
#source "http://gems.github.com"

gemspec

gem 'wagn', :path=>File.expand_path( '../', __FILE__ )

gem 'wagn-dev', :path=>File.expand_path( '../../wagn-dev', __FILE__ )

group :mysql do
  gem "mysql2", "~> 0.3"
end



group :profile do
  gem 'ruby-prof', '~>0.12.1'                  # profiling
  #gem 'test-unit' #was causing errors after cucumber runs.
end

group :test do
  
  # execjs is necessary for developing coffeescript.  mac users have execjs built-in; don't need this one
  gem 'therubyrhino', :platform=>:ruby         # :ruby is MRI rubies, so if you use a mac ruby ...
  
  gem 'rails-dev-tweaks', '~> 0.6'             # dramatic speeds up asset loading, among other tweaks
  gem 'rspec-rails', "~> 2.6"                  # behavior-driven-development suite
  
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

group :debug do
  case RUBY_VERSION
  when /^1\.9\.3-p0/
    gem 'linecache19', '~>0.5.13'
    gem 'ruby-debug-base19x', '~> 0.11.30.pre4'
  when /^1\.9/
    gem 'ruby-debug19', :require => 'ruby-debug'
  when /^1\.8/
    gem 'ruby-debug'
  end
end



