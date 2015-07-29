# -*- encoding : utf-8 -*-

class UpdateFileAndImageCards < Card::CoreMigration
  def up
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
            codecard = card.cardname.junction? ? card.left : card
            card.update_attributes :content=>":#{codecard.codename}/#{attach_array[3]}.#{extension}"
          else
            card.update_attributes :content=>"~#{card.id}/#{card.last_action_id}.#{extension}"
          end
        end
      end
    end
  end
end
