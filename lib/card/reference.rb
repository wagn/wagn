# -*- encoding : utf-8 -*-
class Card::Reference < ActiveRecord::Base
  def referencer
    Card[referer_id]
  end

  def referencee
    Card[referee_id]
  end

  class << self
    
    def delete_all_from card
      delete_all :referer_id => card.id
    end
    
    def delete_all_to card
      where( :referee_id => card.id ).update_all :present=>0, :referee_id => nil
    end
    
    def update_existing_key card, name=nil
      key = (name || card.name).to_name.key
      where( :referee_key => key ).update_all :present => 1, :referee_id => card.id
    end

    def update_on_rename card, newname, update_referers=false
      if update_referers
        # not currentlt needed because references are deleted and re-created in the process of adding new revision
        #where( :referee_id=>card.id ).update_all :referee_key => newname.to_name.key
      else
        delete_all_to card
      end
      #Rails.logger.warn "update on rename #{card.inspect}, #{newname}, #{update_referers}"
      update_existing_key card, newname
    end

    def update_on_delete card
      delete_all_from card
      delete_all_to card
    end
    
    def repair_missing_referees
      where( Card.where( :id=>arel_table[:referee_id]).exists.not ).update_all :referee_id=>nil
    end
    
    def repair_all
      connection.execute 'truncate card_references'
      Card.update_all :references_expired => 1

      expired_cards_remain = true
      batchsize, count_updated = 100, 0

      while expired_cards_remain
        batch = Card.find_all_by_references_expired(1, :order=>"name ASC", :limit=>batchsize)
        if batch.empty?
          expired_cards_remain = false
        else
          Rails.logger.debug "Updating references for '#{batch.first.name}' to '#{batch.last.name}' ... "; $stdout.flush        
          batch.each do |card|
            count_updated += 1
            card.update_references
          end
          Rails.logger.info "batch done.  \t\t#{count_updated} total updated"
        end
      end
      
    end
    
  end

end
