# -*- encoding : utf-8 -*-

class UriCodename < Wagn::Migration
  def up
    contentedly do
      puts "adding new codename card for URI"
      targetname = 'URI'
      codename = targetname.to_name.key
      if Card.exists? codename.to_sym
        raise "Migration failed, codename #{codename} taken"
      else
        c=Card.create! :type_id=>Card::CardtypeID, :name=>targetname, :codename=>codename, :find_unused_name=>true
        puts "Name #{targetname} was taken, used #{c.name}" if c.name != targetname
      end
    end
  end
end
