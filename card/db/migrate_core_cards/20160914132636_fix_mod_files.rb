# -*- encoding : utf-8 -*-

class FixModFiles < Card::Migration::Core
  def up
    Card.search(type: "image").each do |card|
      next unless card.coded?
      next unless card.content.include?("05_standard") ||
                  card.content.include?("06_bootstrap")
      new_content = card.content.sub("05_standard", "standard")
                        .sub("06_bootstrap", "bootstrap")
      card.update_column :db_content, new_content

      update_history card
    end
  end

  def update_history card
    card.actions.each do |action|
      next unless (content_change = action.change(:db_content))
      new_value = content_change.value.gsub("05_standard", "standard")
                                .gsub("06_bootstrap", "bootstrap")
      content_change.update_column :value, new_value
    end
  end
end
