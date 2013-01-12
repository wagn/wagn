class AdminCards < ActiveRecord::Migration

  CODE_CARD = [ :setup, :cache, :session ]

  def up
    Account.as_bot do
      CODE_CARD.each do |code|
        Card.create! :name=>code.to_s.camelcase, :codename=>code #, :type_id=>Card::???ID
      end
    end
  end

  def down
    Account.as_bot do
      CODE_CARD.each do |code|
        begin
        c=Card[code]
        c.codename=nil
        c.save!
        c.destroy
        rescue
        end
      end
    end
  end
end
