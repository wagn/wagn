# -*- encoding : utf-8 -*-
module WagnMigrationHelper

  # "pristine" here refers to cards that have not been edited directly by human users.  bleep blorp.
  def create_or_update_pristine card, typecode, content
    if card.revisions.any? && card.revisions.map(&:creator).map(&:login).uniq != ["wagn_bot"]
      say "#{card.name} has been edited; leaving as is.", :yellow
      return false
    end
    create_or_update(card, typecode, content)
  end
  
  def create_or_update card, typecode, content
    Account.as_bot do
      card = card.refresh if card.frozen?
      card.typecode = typecode
      card.content = content
      card.save!
    end    
  end
  
  def contentedly &block
    ar_suffix = ActiveRecord::Base.table_name_suffix
    ActiveRecord::Base.table_name_suffix = ''
    Account.as_bot do
      Wagn::Cache.reset_global
      ActiveRecord::Base.transaction do
        begin
          yield
        ensure
          Wagn::Cache.reset_global
        end
      end
    end
    ActiveRecord::Base.table_name_suffix = ar_suffix
  end
  
end
