# -*- encoding : utf-8 -*-

class SearchCardContext < Card::CoreMigration
  def up
    sep = %r{\W}
    replace = [
      ['[lr]+','l\\1'],
      ['[LR]+','L\\1'],
      ["(?=[lrLR]+#{sep})(?=[LR]*[lr]+)(?=[lr]*[LR]+).*",'l\\1'],   # mix of lowercase and uppercase l's and r's
      ['left',   'LL'],
      ['right',  'LR'],
      ['self',   'left'],
      ['',       'left'],
    ]
    Card.search(:type=>'search').each do |card|
      if card.cardname.junction?
        content = card.content
        replace.each do |key, val|
          content.gsub!(/(?<=#{sep})_(#{key})(?=#{sep})/, "_#{val}")
        end
        card.update_attributes! :content=>content
      end
    end
  end
end
