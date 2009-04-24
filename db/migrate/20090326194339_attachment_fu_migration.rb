# required to use ActionController::TestUploadedFile 
require 'action_controller'
require 'action_controller/test_process.rb'

# mimetype is a string like "image/jpeg". One way to get the mimetype for a given file on a UNIX system

# This will "upload" the file at path and create the new model.
class AttachmentFuMigration < ActiveRecord::Migration
  def self.up   
    User.as(:admin)         
    (Card::Image.find(:all) + Card::File.find(:all)).each do |card|
      path_segment,attachable_model = (card.class == Card::Image) ? ["image",CardImage] : ["file",CardFile]
      
      path = "#{RAILS_ROOT}/public/#{path_segment}/#{card.content}"
      if !card.content.blank? and File.exists?(path)
        mimetype = `file -ib "#{path}"`.gsub(/\n/,"")
        puts "uploading #{mimetype} #{path}"
        begin
          attachable = attachable_model.new(:uploaded_data => ActionController::TestUploadedFile.new(path, mimetype))
          attachable.save!

          card.content = attachable.preview
          card.attachment_id = attachable.id
          card.save!
        rescue Exception=>e
          puts "ERROR: #{e.message}"
        end
      else
        puts "MISSING FILE #{path}"
      end
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
