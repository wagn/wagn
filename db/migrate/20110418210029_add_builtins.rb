class AddBuiltins < ActiveRecord::Migration
  def self.builtin_list
    %w{ *account_link *alerts *foot *head *navbox *now *version 
        *recent_change *search *broken_link }
  end

  def self.up
    User.current_user = :wagbot
    builtin_list.each do |name|
      c = Card.fetch_or_create(name)
    end
  end

  def self.down
    User.current_user = :wagbot
    builtin_list.each do |name|
      if c = Card.fetch(name)
        c.destroy!
      end
    end    
  end
end
