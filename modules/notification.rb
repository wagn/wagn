module Notification 
  module Hooks
    def before_multi_save( card, multi_card_params )
      multi_card_params.each_pair do |name, opts|
        opts[:nested_edit] = card
      end  
      card.nested_notifications = []
    end 
  
    def after_multi_update( card )                  
      if card.nested_notifications.present?  
        card.watcher_watched_pairs.each do |watcher, watched|
          Mailer.deliver_change_notice( watcher, card, 'updated', watched, card.nested_notifications )
        end
      end
    end
  end
  
  module CardMethods
    def send_notifications 
      action = case  
        when trash;  'deleted'
        when updated_at.to_s==created_at.to_s; 'added'
        when updated_at.to_s==current_revision.created_at.to_s;  'edited'  
        else; 'updated'
      end
      
      @trunk_watcher_watched_pairs = trunk_watcher_watched_pairs
      @trunk_watchers = @trunk_watcher_watched_pairs.map(&:first)
      
      watcher_watched_pairs.reject {|p| @trunk_watchers.include?(p.first) }.each do |watcher, watched|
        Mailer.deliver_change_notice( watcher, self, action, watched )
      end
      
      if nested_edit
        nested_edit.nested_notifications << [ name, action ]
      else
        @trunk_watcher_watched_pairs.each do |watcher, watched|
          Mailer.deliver_change_notice( watcher, self.trunk, 'updated', watched, [[name, action]], self )
        end
      end
    end  
    
    def trunk_watcher_watched_pairs
      # do the watchers lookup before the transcluder test since it's faster.
      if (name.junction? and 
          pairs = CachedCard.get("#{name.trunk_name}").watcher_watched_pairs and
          transcluders.include?(trunk))
        pairs
      else
        []
      end
    end
    
    def self.included(base)   
      super                             
      base.class_eval do                
        attr_accessor :nested_edit, :nested_notifications
        after_save :send_notifications
      end
    end
  end
  
  module CacheableMethods
    def watcher_watched_pairs
      author = User.current_user.card.name
      (card_watchers.except(author).map {|watcher| [Card[watcher].extension,self.name] }  +
        type_watchers.except(author).map {|watcher| [Card[watcher].extension,::Cardtype.name_for(self.type)]})
    end
    
    def card_watchers 
      pointees_from("#{name}+*watchers")
    end
    
    def type_watchers
      pointees_from(::Cardtype.name_for( self.type ) + "+*watchers" )
    end
    
    def pointees_from( cardname )
      (c = CachedCard.get(cardname)) ? c.pointees.reject{|x|x==''} : []
    end  
      
    def watchers
      card_watchers + type_watchers
    end
  end    

  module SlotHelperMethods     
    def watch_link 
      return "" unless logged_in?   
      return "" if card.virtual? 
      me = User.current_user.card.name          
      if card.type == "Cardtype"
        (card.type_watchers.include?(me) ? "#{watching_type_cards} | " : "") +  watch_unwatch
      else
        if card.type_watchers.include?(me) 
          watching_type_cards
        else
          watch_unwatch
        end
      end
    end

    def watching_type_cards
      "watching #{link_to_page(Cardtype.name_for(card.type))} cards"      # can I parse this and get the link to happen? that wud r@wk.
    end

    def watch_unwatch      
      type_link = (card.type == "Cardtype") ? " #{card.name} cards" : ""
      type_msg = (card.type == "Cardtype") ? " cards" : ""    
      me = User.current_user.card.name   

      if card.card_watchers.include?(me) or card.type != 'Cardtype' && card.watchers.include?(me)
  			slot.link_to_action( "unwatch#{type_link}", 'unwatch', {:update=>slot.id("watch-link")},{
  			  :title => "stop getting emails about changes to #{card.name}#{type_msg}"})
  		else
  			slot.link_to_action( "watch#{type_link}", 'watch', {:update=>slot.id("watch-link")},{
          :title=>"get emails about changes to #{card.name}#{type_msg}" })
  		end
    end
  end
  
  def self.init
    Card::Base.send :include, CardMethods
    Card::Base.send :include, CacheableMethods  
    CachedCard.send :include, CacheableMethods 
    Slot.send :include, SlotHelperMethods 
    self.extend Hooks 
  end   
end    

Notification.init



