source 'http://rubygems.org'
#source "http://gems.github.com"

# ~~~~~~~ #
# DEFAULT #
# ~~~~~~~ #

# must have all of these

gem 'rails', '~>3.1'
gem 'htmlentities'#, '~>4.2.1'
gem 'uuid'
gem 'jquery-rails'
#gem 'ruby-openid'#, '~>2.1.8'


# ~~~~~~~~~ #
# DATABASES #
# ~~~~~~~~~ #

# need at least one of the following

#gem 'sqlite3-ruby', :require => 'sqlite3', :group=>'sqlite'
group :postgres do
  RUBY_VERSION =~ /^1\.9/ ?
    gem('pg', '~>0.7') :
    gem('postgres', '~>0.7.9.2008.01.28')
end
gem 'mysql', '~>2.8.1',                :group=>'mysql'

# ~~~~~~~~~~~~~~ #
# IMAGE HANDLING #
# ~~~~~~~~~~~~~~ #

# This is important for image re-sizing, which is vital to Image cards.

group :image_science do
#  gem 'image_science', '~>1.2.1'
#  gem 'RubyInline', '~>3.8.4'
end
#gem 'rmagick', '>=2.13.1',    :group=>'rmagick'

# ~~~~~~~ #
# HOSTING #
# ~~~~~~~ #

group :hosting do
#  gem 'hoptoad_notifier', '>=2.3.12'
  gem 'aws-s3','>=0.6.2'
  gem 'newrelic_rpm', '>=2.14.1'
end

group :debug do
  gem 'rdoc'
  gem 'ruby-debug19', :require => 'ruby-debug'
end

group :test, :development do
  gem 'rspec-rails', "~> 2.6"                  # behavior-driven-development suite
  gem 'ruby-prof'                              # profiling
  gem 'rails-dev-tweaks', '~> 0.5.1'           # dramatic speeds up asset loading, among other tweaks
end

group :test do
  gem 'cucumber-rails', '~>1.1.1'              # feature-driven-development suite
  gem 'minitest'                               # cucumber breaks without this.  m
  gem 'launchy'                                # lets cucumber launch browser windows
  gem 'timecop'                                # not clear on use/need.  referred to in shared_data.rb
  gem 'spork'                                  #
                                               
  gem 'email_spec'                             # using?
  gem 'database_cleaner'                       # using?
  gem "jspec", "~> 4.3.3"                      # javascript testing
  gem 'turn', "<0.8.3", :require => false      # Pretty printed test output.  (version constraint is to avoid minitest requirement)
  
  #windows stuff
  gem 'win32console', '1.3.0', :platforms => ['mingw', 'mswin']
  gem 'win32-process', '0.6.5', :platforms => ['mingw', 'mswin']
end


group :assets do
  gem 'sass-rails', "  ~> 3.1.0"
  gem 'coffee-rails', "~> 3.1.0"
  gem 'uglifier'
end



# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'


# original list http://groups.google.com/group/wagn-dev/browse_thread/thread/79ff17d0bd1145e0/d822516dc749db89#d822516dc749db89
