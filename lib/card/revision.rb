# -*- encoding : utf-8 -*-
class Card
  class Revision
    class << self
      # def cache
      #   Wagn::Cache[Card::Revision]
      # end
    
      def delete_old  #ACT  
        # => where( Card.where( :current_revision_id=>arel_table[:id] ).exists.not ).delete_all  #ACT<revision>
        
        Card.find_each do |card|
          last_action_ids = Card::TRACKED_FIELDS.map do |field|
            if last_change = card.last_change_on(field)
              last_change.card_action_id
            else
              nil
            end
          end.compact.uniq
          card.actions.where('id NOT IN (?)', last_action_ids ).delete_all
        end    
        delete_empty_acts    
      end
    
      def delete_cardless  #ACT
        #Card::Action.where(Card.where( :id=>arel_table[:card_id] ).exists.not ).delete_all
        Card::Action.find_each do |a|
          a.delete unless Card.exists?(a.card_id)
        end
      end
      
      def delete_empty_acts
        Card::Act.find_each do |act|       #FIXME better sql here
          act.delete if act.actions.empty?
        end
      end
    end

    def title #ENGLISH        #ACT<revision>
      current_id = card.current_revision_id
      if id == current_id
        'Current Revision'
      elsif id > current_id
        'AutoSave'
      else
        card.revisions.each_with_index do |rev, index|
          return "Revision ##{index + 1}" if rev.id == id
        end
        '[Revisions Missing]'
      end
    end
    
  end
end
