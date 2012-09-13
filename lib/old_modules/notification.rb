module Notification   
  module CardMethods
    def self.included(base)   
      super                             
      base.class_eval { attr_accessor :nested_notifications }
    end
    
    def send_notifications
      return false if Card.record_userstamps==false
      # userstamps and timestamps are turned off in cases like updating read_rules that are automated and 
      # generally not of enough interest to warrant notification
      
      action = case  
        when trash;  'deleted'
        when @was_new_card; 'added'
        when nested_notifications; 'updated'
        when updated_at.to_s==current_revision.created_at.to_s;  'edited'  
        else; 'updated'
      end
      
      @trunk_watcher_watched_pairs = trunk_watcher_watched_pairs
      @trunk_watchers = @trunk_watcher_watched_pairs.map(&:first)      
      
      watcher_watched_pairs.reject {|p| @trunk_watchers.include?(p.first) }.each do |watcher, watched|
        next unless watcher && mail=Mailer.change_notice(
                 watcher, self, action, watched, nested_notifications )
        mail.deliver
      end
      
      if nested_edit
        nested_edit.nested_notifications ||= []
        nested_edit.nested_notifications << [ name, action ]
      else
        @trunk_watcher_watched_pairs.compact.each do |watcher, watched|
          next unless watcher
          Mailer.change_notice( watcher, self.trunk, 'updated', watched, [[name, action]], self ).deliver
        end
      end
    rescue Exception=>e
      Airbrake.notify e if Airbrake.configuration.api_key
      Rails.logger.info "\nController exception: #{e.message}"
      Rails.logger.debug e.backtrace*"\n"
    end
    
    def trunk_watcher_watched_pairs
      # do the watchers lookup before the transcluder test since it's faster.
      if cardname.junction?
        #Rails.logger.debug "trunk_watcher_pairs #{name}, #{name.trunk_name.inspect}"
        if tcard = Card[tname=cardname.trunk_name] and
          pairs = tcard.watcher_watched_pairs and
          transcluders.map(&:key).member?(tname.to_key)
          return pairs
        end
      end
      []
    end
    
    def watcher_watched_pairs
      author = User.current_user.card.cardname
      watchers.except(     author).map { |watcher| [ Card[watcher].extension, self.cardname ] } +
      type_watchers.except(author).map { |watcher| [ Card[watcher].extension, self.typename ] }
    end
    
    
    def items_from( name )
      #Rails.logger.info "items_from (#{name.inspect})"
      User.as :wagbot do
        (c = Card[name.to_cardname]) ? c.item_names.reject{|x|x==''}.map(&:to_cardname) : []
      end
    end  


    def watchers()        items_from "#{name}+*watchers"                      end
    def type_watchers()   items_from "#{self.typename}+*watchers"             end
    def watching?()       watchers.include?      User.current_user.card.name  end
    def watching_type?()  type_watchers.include? User.current_user.card.name  end
    
  end    


  def self.init
    Card.send :include, CardMethods
  end   
end    

Notification.init



