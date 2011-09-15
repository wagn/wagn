source 'http://rubygems.org'
#source "http://gems.github.com"

# ~~~~~~~ #
# DEFAULT #
# ~~~~~~~ #

# must have all of these

gem 'rails', '2.3.11'
gem 'rack', '>=1.1.0'
gem 'rake', '>=0.8.7'

gem 'htmlentities', '~>4.2.1'
gem 'macaddr', '~>1.0.0'
gem 'uuid', '~>2.2.0'
gem 'json', '~>1.4.6'
#gem 'userstamp', '~>2.0.1'

#gem 'ruby-openid', '2.1.8'


# ~~~~~~~~~ #
# DATABASES #
# ~~~~~~~~~ #

# need at least one of the following

#gem 'sqlite3-ruby', :require => 'sqlite3', :group=>'sqlite'
gem 'pg', '~>0.7',        :group=>'postgres'
gem 'mysql', '~>2.8.1',                :group=>'mysql'

# ~~~~~~~~~~~~~~ #
# IMAGE HANDLING #
# ~~~~~~~~~~~~~~ #

# This is important for image re-sizing, which is vital to Image cards.
# the attachment_fu plug

group :image_science do
#  gem 'image_science', '~>1.2.1'
#  gem 'RubyInline', '~>3.8.4'
end
#gem 'rmagick', '>=2.13.1',    :group=>'rmagick'

# ~~~~~~~ #
# HOSTING #
# ~~~~~~~ #

group :hosting do
  gem 'hoptoad_notifier', '>=2.3.12'
  gem 'aws-s3','>=0.6.2'
  gem 'newrelic_rpm', '>=2.14.1'
end

# ~~~~~~~ #
# TESTING #
# ~~~~~~~ #

group :debug do
  gem 'rdoc'
  gem 'ruby-debug19'
end

group :test do
  gem 'win32console', '1.3.0', :platforms => ['mingw', 'mswin']
  gem 'win32-process', '0.6.5', :platforms => ['mingw', 'mswin']
  
  gem 'test-unit', '1.2.3'
  gem 'term-ansicolor', '1.0.5'
  gem 'nokogiri', '1.4.1'
  gem 'timecop', '>=0.2.1'
  gem 'spork', '>=0.5.7'
  gem 'assert2', '0.5.5'
  gem 'webrat', '>=0.7.0'
  gem 'rspec', '~>1.3', :require=>'spec'
  gem 'rspec-rails', '~>1.3'
  gem 'email_spec', '~>0.6.2'
  gem 'gherkin', '>=2.2.8'
  gem 'cucumber', '>=0.9.2'
  gem 'cucumber-rails', '0.3.2'
  gem 'database_cleaner', '0.5.0'
  
#  gem 'ZenTest', '4.4.0'
#  gem 'autotest-rails', '<= 4.1.0'
#  gem 'autotest-growl' , '0.2.6', :platforms => ['ruby']
#  gem 'ruby-snarl', :platforms => ['mingw', 'mswin']
end

# original list http://groups.google.com/group/wagn-dev/browse_thread/thread/79ff17d0bd1145e0/d822516dc749db89#d822516dc749db89
