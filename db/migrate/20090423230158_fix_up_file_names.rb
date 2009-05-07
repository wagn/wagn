class FixUpFileNames < ActiveRecord::Migration
  def self.up
    User.as :wagbot
    Card::File.find(:all).each do |c|
      if c.attachment
        c.content=c.attachment.preview 
        c.save!
      end
    end
  end

  def self.down
  end
end
