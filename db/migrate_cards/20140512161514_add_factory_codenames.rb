# -*- encoding : utf-8 -*-

class AddFactoryCodenames < ActiveRecord::Migration
  include Wagn::MigrationHelper
  def up
    contentedly do
      Card.create! :name=>'*product', :codename=>:product, :type_id=>Card::FileID
      Card.create! :name=>'*supplies', :codename=>:supplies, :type_id=>Card::PointerID
    end
  end
end
