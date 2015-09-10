# -*- encoding : utf-8 -*-

class SearchCardContext < Card::CoreMigration
  def up
    sep = %r{\W}
    replace = [
      ['[lr]+','l\\1'],
      ['[LR]+','L\\1'],
      ['(?=[LR]*[lr]+)(?=[lr]*[LR]+)[lrLR]+','l\\1'],   # mix of lowercase and uppercase l's and r's
      ['left',   'LL'],
      ['right',  'LR'],
      ['self',   'left'],
      ['',       'left'],
    ]
    Card.search(:type_id=>['in', Card::SearchTypeID, Card::SetID]).each do |card|
      if card.cardname.junction?
        content = card.content
        replace.each do |key, val|
          content.gsub!(/(?<=#{sep})_(#{key})(?=#{sep})/, "_#{val}")
        end
        card.update_column :db_content, content
        card.actions.each do |action|
          if (content_change = action.change_for(:db_content).first)
            content = content_change.value
            replace.each do |key, val|
              content.gsub!(/(?<=#{sep})_(#{key})(?=#{sep})/, "_#{val}")
            end
            content_change.update_column :value, content
          end
        end
      end
    end
  end
end
