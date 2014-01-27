require File.expand_path('../boot', __FILE__)

require 'wagn/all'


module WagnTest
  class Application < Wagn::Application
    
    config.encoding = "utf-8"

    config.recaptcha_public_key  = '6LdhRssSAAAAAFfLt1Wkw43hoaA8RTIgso9-tvtc'
    config.recaptcha_private_key = '6LdhRssSAAAAAGwzl069pJQBdmzCZigm1nV-dmqK'
    
  end
end
