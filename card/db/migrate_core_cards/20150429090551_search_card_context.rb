# -*- encoding : utf-8 -*-

class SearchCardContext < Card::CoreMigration
  def up
    sep = %r{\W}
    replace = [
      ['[lrLR]+','L\\2'],
      ['left',   'LL'],
      ['right',  'LR'],
      ['self',   'left'],
      ['',       'left'],
    ]
    Card.search(:type=>'search').each do |card|
      if card.cardname.junction?
        content = card.content
        replace.each do |key, val|
          content.gsub!(/(#{sep})_(#{key})(#{sep})/, "\\1_#{val}\\3")
        end
        card.update_attributes! :content=>content
      end
    end
  end
end
