require 'wagn/cache'

class CodenameTable < ActiveRecord::Migration

  def self.up
    Wagn::Cache.new_all

    create_table "card_codenames", :force => true, :id => false do |t|
      t.integer  "card_id", :null => false
      t.string   "codename", :null => false
    end

    change_column "cards", "typecode", :string, :null=>true

    Card.as Card::WagbotID do
      Card::Codename::CODENAMES.each do |name|
        if card = Card[name] # || Card.create!(:name=>name)
          card or raise "Missing codename #{name} card"
        
          warn Rails.logger.warn("codename for #{name}, #{Card::Codename.name2code(name)}")
          Card::Codename.create :card_id=>card.id,
                                :codename=>Card::Codename.name2code(name)

        else warn Rails.logger.warn("missing card for #{name}")
        end
      end
    end

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
