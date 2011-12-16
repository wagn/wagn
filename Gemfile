source 'http://rubygems.org'
#source "http://gems.github.com"

# DEFAULT

gem 'rails', '~> 3.1'
gem 'htmlentities', '~>4.3.0'
gem 'uuid', '~>2.3.4'
gem 'paperclip', '~>2.4'
gem 'devise', '>1.0.9'
gem 'warden', '>0.10.1'
#gem 'rmagick', '~>2.13.1'

# DATABASE

# need at least one of the following

gem 'mysql', '~>2.8.1', :group=>'mysql'

group :postgres do
  ENV['RUBY_VERSION']||RUBY_VERSION =~ /^(1\.9|ree)/ ?
    gem('pg', '~>0.7') :
    gem('postgres', '~>0.7.9.2008.01.28')
end
#gem 'sqlite3-ruby', :require => 'sqlite3', :group=>'sqlite'


# These should only be needed if you're developing new JS / CSS.  It's all pre-compiled for production
group :assets do
  gem 'sass-rails',   "~> 3.1.0"               # pretty code; compiles to CSS
  gem 'coffee-rails', "~> 3.1.0"               # pretty code; compiles to JS
  gem 'uglifier'                               # makes pretty code ugly again.  compresses js/css for fast loading

  gem 'jquery-rails', '~> 1.0.17'              # main js framework, along with rails-specific unobtrusive lib
#  gem 'jquery.fileupload-rails'                # jquery plugin for uploading files
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
  gem 'cucumber-rails', '~>1.2.0'              # feature-driven-development suite
  gem 'launchy'                                # lets cucumber launch browser windows
  gem 'timecop'                                # not clear on use/need.  referred to in shared_data.rb
  gem 'spork'                                  #
                                               
  gem 'email_spec'                             # using?
  gem 'database_cleaner'                       # using?
  gem 'turn', "<0.8.3", :require => false      # Pretty printed test output.  (version constraint is to avoid minitest requirement)
  
  #windows stuff
  gem 'win32console', '1.3.0', :platforms => ['mingw', 'mswin']
  gem 'win32-process', '0.6.5', :platforms => ['mingw', 'mswin']
end

group :debug do
  gem 'rdoc'
  RUBY_VERSION =~ /^1\.9/ ?
    gem('ruby-debug19', :require => 'ruby-debug') :
    gem('ruby-debug')
end


# ~~~~~~~ #
# HOSTING #
# ~~~~~~~ #

#group :hosting do
##  gem 'hoptoad_notifier', '>=2.3.12'
##  gem 'aws-s3','>=0.6.2'
#  gem 'newrelic_rpm', '>=2.14.1'
#end

