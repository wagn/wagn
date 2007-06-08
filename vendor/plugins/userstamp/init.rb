# plugin init file for rails
# this file will be picked up by rails automatically and
# add the userstamp extensions to rails

require 'userstamp'

ActiveRecord::Base.send(:include, ActiveRecord::Userstamp)