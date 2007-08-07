load 'db/card_creator.rb'

class MTagRevision
end
class MRevision
  #def revised_at=(value)
  #  self.updated_at=value
  #end
end
   

class AddInvitationRequestCardtype < ActiveRecord::Migration
  
  class << self
    include CardCreator
  end
  
  def self.up  
    MTagRevision.class_eval <<-DEF
      def revised_at=(value)
        self.updated_at=value
      end
    DEF
    MRevision.class_eval <<-DEF
      def revised_at=(value)
        self.updated_at=value
      end
    DEF

    MCard.reset_column_information
    MTagRevision.reset_column_information
    MRevision.reset_column_information
    MTag.reset_column_information
    #::User.as(:admin) do  Card::Cardtype.create :name=>"InvitationRequest" end
    create_cardtype_card 'InvitationRequest' 
  end

  def self.down
  end
end
