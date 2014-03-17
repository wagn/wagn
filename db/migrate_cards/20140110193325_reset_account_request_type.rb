# -*- encoding : utf-8 -*-

class ResetAccountRequestType < ActiveRecord::Migration
  include Wagn::MigrationHelper
  def up
    contentedly do
      arcard = Card[:signup]
      if arcard.type_code != :cardtype
        arcard.update_attributes :type_id=>Card::CardtypeID
      end
    end
  end

end
