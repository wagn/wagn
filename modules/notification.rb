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
      (card_watchers.except(author).map {|watcher| [Card[watcher].extension,self.cardname] }  +
        type_watchers.except(author).map {|watcher|
        #Rails.logger.info "watcher #{watcher.inspect}, #{::Cardtype.name_for(self.typecode)}"
        [cd=Card[watcher].extension,::Cardtype.name_for(self.typecode)]})
    end
    
    def card_watchers 
      #Rails.logger.debug "card_watchers #{name}"
      items_from("#{name}+*watchers")
    end
    
    def type_watchers
      #Rails.logger.debug "type_watchers #{Cardtype.name_for(self.typecode).to_s+"+*watchers"}"
      items_from("#{Cardtype.name_for(self.typecode).to_s}+*watchers" )
    end
    
    def items_from( name )
      #Rails.logger.info "items_from (#{name.inspect})"
      User.as :wagbot do
        (c = Card[name.to_cardname]) ? c.item_names.reject{|x|x==''}.map(&:to_cardname) : []
        #(c = Card[name.to_cardname]) ?
        #  begin
        #  r1=c.item_names; r2=r1.reject{|x|x==''}; r3=r2.map(&:to_cardname)
        #  Rails.logger.info "items from 2 #{c.new_record?}, #{r1.inspect}, #{r2.inspect}, #{r3.inspect}"; r3
        #  end : []
      end
    end  
      
    def watchers
      card_watchers + type_watchers
    end
  end    


  def self.init
    Card.send :include, CardMethods
  end   
end    

Notification.init



