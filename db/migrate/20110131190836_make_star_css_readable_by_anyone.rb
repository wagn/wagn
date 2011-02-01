class MakeStarCssReadableByAnyone < ActiveRecord::Migration
  def self.up
    User.as(:wagbot) do
      if card = Card['*css']
        card.permit :read, Role[:anon]
        card.save!
      end
    end
  end

  def self.down
  end
end
