class AccountTrait < ActiveRecord::Migration
  def up
    Session.as_bot do
      User.all.each do |user|
        #next if user.card_id == Card::WagnBotID || user.card_id == Card::AnonID
        card = Card.find user.card_id
        if account = card.fetch(:trait=>:account, :new=>{})
          account.save!
          user.account_id = account.id
          user.save!
        end
        Rails.logger.warn "update card_id #{card.inspect}, #{account.inspect}, #{user.card_id}"
      end
    end
  end

  def down
    Session.as_bot do
      Card.search(:right=>Card::AccountID).items { |c| c.delete; }
    end
  end
end
