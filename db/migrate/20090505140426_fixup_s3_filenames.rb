class FixupS3Filenames < ActiveRecord::Migration
  def self.up    
    if System.attachment_storage == :s3
      User.as :wagbot
      Card::File.find(:all).each do |c|
        if c.attachment
          c.content=c.attachment.preview 
          c.save!
        end
      end
    end
  end

  def self.down
  end
end
