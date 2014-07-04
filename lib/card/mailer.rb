<<<<<<< Local Changes
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

    def change_notice watcher, watched_card, action, watched, nested_notifications 
      watched_card.format(:format=>:email)._render_change_notice(
                :watcher=>watcher, :watched=>watched.to_s, :action=>action, :subedits=>nested_notifications )
  end
end
