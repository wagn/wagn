class Notifier
  cattr_accessor :max_interval
  @@max_interval = 24.hours
  
  class << self
    def recently_changed
      Card.find :all, :conditions => ["updated_at > ?", Time.now - max_interval]
    end
    
    # def send_notifications
    #   rev = card.current_revision
    # 
    #   # FIXME this logic duplicated somewhat in _change view
    #   action = case card.updated_at.to_s
    #     when card.created_at.to_s; 'added'
    #     when rev.created_at.to_s;  'edited'
    #     else; 'updated'
    #   end
    # 
    # end
    # 
  end
end