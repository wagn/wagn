require 'wagn/cache'

class CodenameTable < ActiveRecord::Migration

  def self.up
    Wagn::Cache.new_all

    create_table "card_codenames", :force => true, :id => false do |t|
      t.integer  "card_id", :null => false
      t.string   "codename", :null => false
    end

    change_column "cards", "typecode", :string, :null=>true

    cardnames.each do |name|
      if card = Card[name] # || Card.create!(:name=>name)
        Card::Codename.create :card_id=>card.id, :codename=>name2code(name)
      else
        raise "Missing codename #{name} card"
        #puts "missing card for #{name}"
      end
    end
    Wagn::Cache.reset_global
    Card::Codename.reset_cache

    Card.reset_column_information
  end


  def name2code(name)
    code = ?* == name[0] ? name[1..-1] : name
    code = @@renames[code] if @@renames[code]
    warn Rails.logger.warn("name2code: #{name}, #{code}, #{@@renames[code]}")
    code
  end


  def self.down
    execute %{
      update cards as c set typecode = code.codename
      from codename code
      where c.type_id = code.card_id
    }

    change_column "cards", "typecode", :string, :null=>false

    drop_table "card_codenames"
  end
end
