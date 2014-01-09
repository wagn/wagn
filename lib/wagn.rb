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
  def self.gem_root
    WAGN_GEM_ROOT
  end
  
  def self.root
    WAGN_APP_ROOT #ugly
  end
end