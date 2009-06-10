class FixupS3Filenames < ActiveRecord::Migration
  def self.up    
    if System.attachment_storage == :s3
      execute %{
         update card_files set revision_id=(
         select current_revision_id from cards c join revisions r on r.card_id=c.id where r.id=revision_id);
       }
      
      User.as :wagbot
      Card::File.find(:all).each do |c|
        if c.attachment
          c.content=c.attachment.preview 
          c.save!
        end
      end

      execute %{
         update card_files set revision_id=(
         select current_revision_id from cards c join revisions r on r.card_id=c.id where r.id=revision_id);
       }

    end
  end

  def self.down
  end
end
