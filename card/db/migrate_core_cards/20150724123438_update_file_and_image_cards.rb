# -*- encoding : utf-8 -*-

class UpdateFileAndImageCards < Card::CoreMigration

  def up

    # use codenames for the filecards not for the left parts
    if (credit = Card[:credit]) && (Card.fetch "#{credit.name}+image")
      card.update_attributes! :codename=>'credit_image'
    end
    %w( cerulean_skin cosmo_skin cyborg_skin darkly_skin flatly_skin journal_skin lumen_skin paper_skin readable_skin sandstone_skin simplex_skin slate_skin spacelab_skin superhero_skin united_skin yeti_skin ).each do |name|
      if (card=Card[name.to_sym])
        card.update_attributes! :codename=>nil
        if (card = Card.fetch "#{card.name}+image")
          card.update_attributes! :codename=>"#{name}_image"
        end
      end
    end

    Card::Cache.reset_global
    Card.search(:type=>[:in, 'file', 'image']).each do |card|
      card.actions.each do |action|
        if (content_change = action.change_for(:db_content).first)
          original_filename = content_change.value.split("\n").first
          action.update_attributes! :comment=>original_filename
        end
      end
      if card.content.present?
        attach_array = card.content.split "\n"
        attach_array[0].match(/\.(.+)$/) do |match|
          extension = $1
          if attach_array.size > 3  # mod file
            card.update_column :db_content, ":#{card.codename}/#{attach_array[3]}.#{extension}"
          else
            card.update_column :db_content, "~#{card.id}/#{card.last_action_id}.#{extension}"
          end
          # swap variant and action_id/type_code in file name
          if Dir.exist? card.store_dir
            symlink_target_hash = Hash.new
            Dir.entries(card.store_dir).each do |file|
              if file =~ /^(icon|small|medium|large|original)-([^.]+).(.+)$/ 
                file_path = File.join(card.store_dir, file)
                new_filename = "#{$2}-#{$1}.#{$3}"
                if File.symlink?(file_path)
                  symlink_target_hash[new_filename] = File.readlink(file_path)
                  File.unlink file_path
                else
                  FileUtils.mv file_path, File.join(card.store_dir, new_filename)
                end
              end
            end
            symlink_target_hash.each do |symlink,target|
              target =~ /^(icon|small|medium|large|original)-([^.]+).(.+)$/ 
              new_target_name = "#{$2}-#{$1}.#{$3}"
              File.symlink File.join(card.store_dir,new_target_name),File.join(card.store_dir,symlink)
            end
          end
        end
      end
    end

  end

end
