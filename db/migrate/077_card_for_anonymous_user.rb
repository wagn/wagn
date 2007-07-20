class CardForAnonymousUser < ActiveRecord::Migration  
  class << self
    User.as_admin do
      include CardCreator
    end
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
    create_user_card 'Anonymous', 'anon'
  end

  def self.down
  end
end
