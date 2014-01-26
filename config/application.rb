require File.expand_path('../boot', __FILE__)

require 'wagn/all'


module WagnTest
  class Application < Wagn::Application
    
    config.encoding = "utf-8"

  end
end
