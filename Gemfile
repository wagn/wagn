source 'http://rubygems.org'
#source "http://gems.github.com"

# DEFAULT

gem 'rails', '~> 3.1'
gem 'htmlentities', '~>4.3.0'
gem 'uuid', '~>2.3.4'
gem 'paperclip', '~>2.4'
gem 'warden'
gem 'rmagick', '~>2.13.1'
gem "recaptcha", "~> 0.3.4"
gem 'userstamp', '~> 2.0'
gem 'xmlscan', '~>0.3.0'

# DATABASE

# need at least one of the following

group :mysql2 do
  gem "mysql2", "~> 0.3.11"
end
group :mysql do
  gem "mysql2", "~> 0.3.11"
  gem 'mysql', '~>2.8.1'
end

group :postgres do
  gem 'pg', '~>0.12.2'
  # if using 1.8.7 or ree and having no luck with the above, try:
  # gem 'postgres', '~>0.7.9.2008.01.28'
end
#gem 'sqlite3-ruby', :require => 'sqlite3', :group=>'sqlite'


gem 'dalli', :group => :memcache


# These should only be needed if you're developing new JS / CSS.  It's all pre-compiled for production
group :assets do
  gem 'sass-rails',   "~> 3.1.0"               # pretty code; compiles to CSS
  gem 'coffee-rails', "~> 3.1.0"               # pretty code; compiles to JS
  gem 'uglifier'                               # makes pretty code ugly again.  compresses js/css for fast loading

  gem 'jquery-rails', '~> 1.0.17'              # main js framework, along with rails-specific unobtrusive lib
  gem 'tinymce-rails', '~> 3.4.7'              # wysiwyg editor
  
  gem 'therubyracer'                           # execjs is necessary for developing coffeescript.  mac users have execjs built-in; don't need this one
end



group :test, :development do
  gem 'rspec-rails', "~> 2.6"                  # behavior-driven-development suite
  gem 'ruby-prof'                              # profiling
  gem 'rails-dev-tweaks', '~> 0.5.1'           # dramatic speeds up asset loading, among other tweaks

#  gem 'jasmine-rails'
end

group :test do
  gem 'cucumber-rails', '~> 1.2.0'              # feature-driven-development suite
  gem 'launchy'                                # lets cucumber launch browser windows
  gem 'timecop'                                # not clear on use/need.  referred to in shared_data.rb
  gem 'spork', '>=0.9'
                                               
  gem 'rr'#, '=1.0.0'

  gem 'email_spec'                             # 
  gem 'database_cleaner', '~> 0.7.0'            # used by cucumber for db transactions
  
  gem 'turn', "~>0.8.3", :require => false      # Pretty printed test output.  (version constraint is to avoid minitest requirement)
  
  #windows stuff
  gem 'win32console', '~> 1.3.0', :platforms => ['mingw', 'mswin']
  gem 'win32-process', '~> 0.6.5', :platforms => ['mingw', 'mswin']
end

group :debug do
  gem 'rdoc'
  if RUBY_VERSION =~ /^1\.9\.3-p0/
    gem 'linecache19', '~>0.5.13'
    gem 'ruby-debug-base19x', '~> 0.11.30.pre4'
  end
  if RUBY_VERSION =~ /^1\.9/
    gem 'ruby-debug19', :require => 'ruby-debug'
  else
    gem 'ruby-debug'
  end
end


# ~~~~~~~ #
# HOSTING #
# ~~~~~~~ #

#group :hosting do
##  gem 'hoptoad_notifier', '>=2.3.12'
#  gem 'newrelic_rpm', '>=2.14.1'
#end

