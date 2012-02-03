require 'open-uri'

class NewFileStorage < ActiveRecord::Migration
  def up
    User.as :wagbot do
      %w{ File Image }.each do |typecode|
        Card.search( :type => typecode ).each do |card|
          card.revisions.each do |revision|
            begin
              filename = filename_for_revision(revision, typecode)
              next unless filename
              card.selected_rev_id = revision.id
              filename = File.join( Rails.root, 'public', filename ) if filename =~ /^\/card/

              file = begin
                  open filename, 'rb'
                rescue
                  open filename.sub( /\.png$/, '.gif' ), 'rb'
                end
              card.attach = file
              card.attach.instance_variable_set("@_attach_file_name", filename) # fixes ext in path
              card.attach_file_name = "#{card.key.gsub('*','X').camelize}#{File.extname(filename)}" # fixes ext in content
            
              revision.update_attribute :content, card.content
              write_file file, card.attach.path(typecode=='Image' ? :original : '')
            
              if typecode == 'Image'
                Card::STYLES.each do |style|
                  next if style == 'original'
                  f = open filename.sub( /\.\w+$/, "_#{style}\\0" ), 'rb'
                  write_file f, card.attach.path( style )
                end
              end
              
            rescue Exception => e
              Rails.logger.info "Migration exception: #{e.message}\n  #{e.backtrace*"\n  "}"
              say "Error converting file for #{card.name}. #{e.message} continuing", :red
            end
          end
        end
      end
    end
  end

  def down
  end
  
  def filename_for_revision( revision, typecode )
    content = revision.content
    return nil if content !~ /^\s*\</
    
    filename = content.match(/(src|href)=\"([^\"]+)/)[2]
    filename.sub!('_medium', '') if typecode == 'Image'
    filename
  end
  
  def write_file( file, path )
    FileUtils.mkdir_p File.dirname(path)
    File.open( path, 'wb' ) do |f| 
      f.write file.read
    end
  end
end
