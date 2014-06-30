# -*- encoding : utf-8 -*-
require 'open-uri'

class Card
  class Mailer < ActionMailer::Base
    
    @@defaults = Wagn.config.email_defaults || {}
    @@defaults.symbolize_keys!
    @@defaults[:return_path] ||= @@defaults[:from] if @@defaults[:from]
    @@defaults[:charset] ||= 'utf-8'
    default @@defaults

    include Wagn::Location
  end
end
