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
        card.watchers.each do |watchername|
          notifyee = Card[watchername].extension
          unless card.updater == notifyee
            Mailer.deliver_change_notice( notifyee, card, 'updated', card.nested_notifications )
          end
        end
      end
    end
  end
  
  module CardMethods
    def send_notifications 
      action = case updated_at.to_s
        when created_at.to_s; 'added'
        when current_revision.created_at.to_s;  'edited'
        else; 'updated'
      end
      
      @watchers, @trunk_watchers = watchers, trunk_watchers

      @watchers.each do |watchername|       
        notifyee = Card[watchername].extension
        unless self.updater == notifyee or @trunk_watchers.include?(watchername)
          Mailer.deliver_change_notice( notifyee, self, action )
        end
      end
      
      if nested_edit
        nested_edit.nested_notifications << [ name, action ]
      else
        @trunk_watchers.each do |watchername|
          notifyee = Card[watchername].extension
          unless self.updater == notifyee
            Mailer.deliver_change_notice( notifyee, self.trunk, 'updated', [name, action] )
          end
        end
      end
    end  

    def trunk_watchers
      return [] unless name.junction? and transcluders.include?(trunk)
      trunk = CachedCard.get("#{name.trunk_name}")
      pointees_from("#{name.trunk_name}+*watchers") + pointees_from(::Cardtype.name_for( trunk.type )+"+*watchers")
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
    def footer
      template.render :inline => %{
        <div class="card-footer">
        	<table>
        		<tr>
        			<td class="links"><%= slot.footer_links %></td>
        			<td class="watch"><span class="watch-link"><%= slot.watch_link %></span></td>
        		</tr>
        	</table>   
        	<span class="height-holder">&nbsp;</span>
        </div> 
      }
    end
    
    def watch_link 
      return "" unless logged_in?
      me = User.current_user.card.name          
      if card.type == "Cardtype"
        (card.type_watchers.include?(me) ? watching_type_cards : "") +  " | #{watch_unwatch}"
      else
        if card.type_watchers.include?(me) 
          watching_type_cards
        else
          watch_unwatch
        end
      end
    end

    def watching_type_cards
      "watching #{link_to_page(card.type)} cards"      # can I parse this and get the link to happen? that wud r@wk.
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
    Card::Base.class_eval {  include CardMethods;  include CacheableMethods  }
    CachedCard.class_eval { include CacheableMethods }
    Slot.class_eval { include SlotHelperMethods }
    self.extend Hooks 
  end   
end    



