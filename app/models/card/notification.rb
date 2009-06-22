module CardLib
  module Notification
    def send_notifications
      action = case updated_at.to_s
        when created_at.to_s; 'added'
        when current_revision.created_at.to_s;  'edited'
        else; 'updated'
      end

      watchers.each do |user_card|
        notifyee = user_card.extension
        unless self.updater == notifyee
          Mailer.deliver_change_notice( notifyee, self, action )
        end
      end
    end

    def self.included(base)   
      super
      base.class_eval do
        after_save :send_notifications
      end
    end
  end
end

