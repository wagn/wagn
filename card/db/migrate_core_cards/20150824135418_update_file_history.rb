# -*- encoding : utf-8 -*-

class UpdateFileHistory < Card::CoreMigration
  def up
    Card.search(type: [:in, 'file', 'image']).each do |card|
      card.actions.each do |action|
        if (content_change = action.change_for(:db_content).first)
          original_filename, file_type, action_id, mod  = content_change.value.split("\n")
          if file_type.present? && action_id.present?
            value =
              if mod.present?
                ":#{card.codename}/#{mod}#{::File.extname(original_filename)}"
              else
                "~#{card.id}/#{action_id}#{::File.extname(original_filename)}"
              end
            content_change.update_attributes! value: value
          end
        end
      end
    end
    Card.search( right: { codename: 'machine_output' } ).each do |card|
      card.delete!
    end
  end
end
