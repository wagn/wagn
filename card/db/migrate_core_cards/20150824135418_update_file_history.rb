# -*- encoding : utf-8 -*-

class UpdateFileHistory < Card::CoreMigration
  def up
    Card.search(:type=>[:in, 'file', 'image']).each do |card|
      card.actions.each do |action|
        if (content_change = action.change_for(:db_content).first)
          original_filename, file_type, action_id, mod  = content_change.value.split("\n")
          if mod.present?
            content_change.update_attributes! :value=>":#{card.codename}/#{mod}#{::File.extname(original_filename)}"
          else
            content_change.update_attributes! :value=>"~#{card.id}/#{action_id}#{::File.extname(original_filename)}"
          end
        end
      end
    end
  end
end
