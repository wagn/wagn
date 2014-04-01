# -*- encoding : utf-8 -*-

class LinkCodename < ActiveRecord::Migration
  include Wagn::MigrationHelper
  def up
    contentedly do
      puts "adding new codename card for link"
      codename = 'Link'
      Card.create! :type_id=>Card::CardtypeID, :name=>codename, :codename=>codename.to_name.key
    end
  end
end
