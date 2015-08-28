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
    Card.search(:type_id=>Card::SearchTypeID).each do |card|
      if card.cardname.junction?
        content = card.content
        replace.each do |key, val|
          content.gsub!(/(?<=#{sep})_(#{key})(?=#{sep})/, "_#{val}")
        end
        card.update_attributes! :content=>content
      end
    end
    Card["*self+*right+*structure"].update_attributes! :content=>'{"name":"_left"}'
    Card["*type+*right+*structure"].update_attributes! :content=>'{"type":"_left"}'
    Card["*type plus right+*right+*structure"].update_attributes! :content=>'{"left":{"type":"_LL"}, "right":"_LR"}'
  end
end
