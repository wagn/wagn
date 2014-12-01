
require 'htmlentities'
require 'recaptcha'
require 'airbrake'
require 'RMagick'
require 'paperclip'
require 'coderay'
require 'haml'
require 'kaminari'
require 'diff/lcs'
require 'diffy'
#require 'scheduler_daemon'

require 'rails/all'

CARD_GEM_ROOT = File.expand_path('../../..', __FILE__)

class Card < ActiveRecord::Base
  class Engine < Rails::Engine
  end

  class << self
    def root
      Rails.root
    end
  
    def application
      Rails.application
    end
    
    def config
      application.config
    end
    
    def paths
      application.paths
    end
    
    def gem_root
      CARD_GEM_ROOT
    end
    
    def future_stamp
      ## used in test data
      @@future_stamp ||= Time.local 2020,1,1,0,0,0
    end
  end

end

