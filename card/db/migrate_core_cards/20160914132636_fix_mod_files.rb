# -*- encoding : utf-8 -*-

class FixModFiles < Card::Migration::Core
  def up
    Card.search(type: "image").each do |card|
      next unless card.coded?
      next unless card.content.include?("05_standard") ||
                  card.content.include?("06_bootstrap")
      new_content = card.content.sub("05_standard","standard")
                                .sub("06_bootstrap","bootstrap")
      card.update_column :db_content, new_content
    end
  end
end
