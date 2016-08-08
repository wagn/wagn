# -*- encoding : utf-8 -*-

class SearchCardContext < Card::CoreMigration
  def up
    sep = /\W/
    replace = [
      ["[lr]+", 'l\\1'],
      ["[LR]+", 'L\\1'],
      ["(?=[LR]*[lr]+)(?=[lr]*[LR]+)[lrLR]+", 'l\\1'],   # mix of lowercase and uppercase l's and r's
      %w(left LL),
      %w(right LR),
      %w(self left),
      ["",       "left"]
    ]
    Card.search(type_id: ["in", Card::SearchTypeID, Card::SetID]).each do |card|
      next unless card.cardname.junction? && card.real?
      content = card.content
      replace.each do |key, val|
        content.gsub!(/(#{sep})_(#{key})(?=#{sep})/, "\\1_#{val}")
      end
      card.update_column :db_content, content
      card.actions.each do |action|
        next unless (content_change = action.change :db_content)
        content = content_change.value
        replace.each do |key, val|
          content.gsub!(/(#{sep})_(#{key})(?=#{sep})/, "\\1_#{val}")
        end
        content_change.update_column :value, content
      end
    end
  end
end
