# -*- encoding : utf-8 -*-

class UriCodename < Wagn::Migration
  def up
    contentedly do
      puts "adding new codename card for URI"
      codename = 'URI'
      Card.create! :type_id=>Card::CardtypeID, :name=>codename, :codename=>codename.to_name.key
    end
  end
end
