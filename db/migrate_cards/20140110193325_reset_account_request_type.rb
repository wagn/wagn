# -*- encoding : utf-8 -*-

class ResetAccountRequestType < ActiveRecord::Migration
  include Wagn::MigrationHelper
  def up
    contentedly do
      arcard = Card[:account_request]
      if arcard.type_code != :cardtype
        arcard.update_attributes :type_id=>Card::CardtypeID
      end
    end
  end

  def down
    contentedly do
      
    end
  end
end
