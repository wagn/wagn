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

    # only used for the mocks in the signup specs; couldn't find a better way so far
    # try to mock the email format class failed
    def change_notice watcher, watched_card, action, watched, nested_notifications 
      watched_card.format(:format=>:email)._render_change_notice(
                :watcher=>watcher, :watched=>watched.to_s, :action=>action, :subedits=>nested_notifications )
    end
    
    def self.layout message
      %{
        <!DOCTYPE html>
        <html>
          <body>
            #{message}
          </body>
        </html>
      }
    end
  end
end
