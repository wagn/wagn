# should be able to move these to more appropriate places
puts "wagn called"

require 'paperclip'
require 'recaptcha'
require 'airbrake'

require 'smart_name'
require 'htmlentities'
require 'uuid'
require 'rmagick'
# require 'xmlscan'
# require 'rubyzip'
require 'coderay'
require 'sass'

module Wagn
  mattr_reader :gem_root, :root
  @@gem_root = File.expand_path('../..', __FILE__)
  @@root ||= File.expand_path('')
end