# -*- encoding : utf-8 -*-

class UriCodename < Card::CoreMigration
  def up
    contentedly do
      cardname = "URI"
      codename = cardname.to_name.key
      okname = Card::Migration.find_unused_name(cardname)
      Card.create! type_id: Card::CardtypeID, name: okname, codename: codename
      puts "Name #{cardname} was taken, used #{okname}" if okname != cardname
    end
  end
end
