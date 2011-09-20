class CodenameTable < ActiveRecord::Migration
  def self.up
    create_table "codename", :force => true do |t|
      t.integer  "card_id", :null => false
      t.string   "codename", :null => false
    end

    #%w{*create *read *update *delete *comment *right *type_plus_right *type *self
    %w{*create *read *update *delete *comment *right *type *self *options *input
       basic cardtype pointer}<<'*options label'. # and so on, need to find all of them
       map { |name|
         c = Card[name] or raise "Missing codename #{name} card"
         Wagn::Codename.insert(c.id, name)
       }
  end


  def self.down
    drop_table "codename"
  end
end
