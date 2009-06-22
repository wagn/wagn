class Notifier
  cattr_accessor :max_interval
  @@max_interval = 24.hours
  
  class << self
    def recently_changed
      Card.find :all, :conditions => ["updated_at > ?", Time.now - max_interval]
    end
    
    def send_notifications
      recently_changed.each do |card|
        # FIXME this logic duplicated somewhat in _change view
        action = case card.updated_at.to_s
          when card.created_at.to_s; 'added'
          when card.current_revision.created_at.to_s;  'edited'
          else; 'updated'
        end

        card.watchers.each do |user_card|
          notifyee = user_card.extension
          unless card.updater == notifyee
            Mailer.deliver_change_notice( notifyee, card, action )
          end
        end
      end
    end
  end
end