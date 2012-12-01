class AccountTrait < ActiveRecord::Migration
  def up
    Wagn::Conf[:migration]=true

    Account.as_bot do
      if related_rule = Card[:account].fetch(:trait=>[:right, :content])
        Rails.logger.warn "delete related rule #{related_rule.inspect}"
        related_rule.confirm_destroy=true
        related_rule.destroy!
      end

      User.where(:status=>'active').each do |user|
        #next if user.card_id == Card::WagnBotID || user.card_id == Card::AnonID
        if card = Card.where( :id=>user.card_id, :trash=>false ).first and
             account = card.fetch(:trait=>:account, :new=>{})
          account.save!
          user.account_id = account.id
          user.save!
        end
        Rails.logger.warn "update card_id #{card.inspect}, #{account.inspect}, #{user.card_id}"
      end
    end
  end

  def down
    Account.as_bot do
      Card.search(:right=>Card::AccountID).each { |c| c.delete; }
    end
  end
end
