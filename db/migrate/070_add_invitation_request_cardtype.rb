class AddInvitationRequestCardtype < ActiveRecord::Migration
  def self.up   
    ::User.as_admin do  Card::Cardtype.create :name=>"InvitationRequest" end
  end

  def self.down
  end
end
