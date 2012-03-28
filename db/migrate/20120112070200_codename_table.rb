class CodenameTable < ActiveRecord::Migration
  def self.up
    create_table "card_codenames", :force => true, :id => false do |t|
      t.integer  "card_id", :null => false
      t.string   "codename", :null => false
    end

    change_column "cards", "typecode", :string, :null=>true

    Card.as Card::WagbotID do
      Card::Codename::CODENAMES.each do |name|
        if card = Card[name] # || Card.create!(:name=>name)
          #puts "codename for #{name}, #{Card::Codename.name2code(name)}"
          Card::Codename.create :card_id=>card.id,
                                :codename=>Card::Codename.name2code(name)

        else
          raise "Missing codename #{name} card"
          #puts "missing card for #{name}"
        end
      end
    end
    Wagn::Cache.reset_global
    Card::Codename.reset_cache

    Card.reset_column_information
  end


  def self.down
    execute %{update cards as c set typecode = code.codename
                from codename code
                where c.type_id = code.card_id
      }

    change_column "cards", "typecode", :string, :null=>false

    drop_table "card_codenames"
  end
end
