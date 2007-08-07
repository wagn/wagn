class CardForAnonymousUser < ActiveRecord::Migration  
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
    User.as(:admin) do 
      create_user_card 'Anonymous', 'anon'
    end
  end

  def self.down
  end
end
