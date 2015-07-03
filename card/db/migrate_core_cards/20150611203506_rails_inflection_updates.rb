# -*- encoding : utf-8 -*-
class RailsInflectionUpdates < Card::CoreMigration
  def word ar
    return [/(?<=\b|_)#{ar[0]}(?=\b|_)/i, /(?<=\b|_)#{ar[1]}(?=\b|_)/i, ar[2]]
  end
  def word_end ar
    return [/#{ar[0]}(?=\b|_)/i, /#{ar[1]}(?=\b|_)/i, ar[2]]
  end

  def keep_the_s word
    return [ "#{word}s", word, "#{word}s" ]
  end

  def up
    card_names = Card.pluck(:name)
    apply_to_content = ::Set.new
    corrections =   [
             # plural,     wrong singular,  correct singular
      word([ '(\w+)lice',  '(\w+)louse',    '\1lice' ]),
      word([ '(\w+)mice',  '(\w+)mouse',    '\1mice' ]),
      word_end([ 'kine',   'cow',           'kine']),
      word( keep_the_s('analysi')),
    ]
    %w( statu crisi testi alia bu axi octopu viru analysi basi diagnosi parenthesi prognosi synopsi thesi ).each do |word|
      corrections << word_end( keep_the_s(word) )
    end

    corrections.each_with_index do |cors, i|
      plural, wrong_sing, correct_sing = cors
      card_names.each do |name|
        if name =~ plural
          apply_to_content << i
          Card.find_by_name(name).update_attributes! :key=>name.to_name.key
        end
      end
    end

    cards_with_css = Card.search :type=>['in','html', 'css', 'scss']
    cards_with_css.each do |card|
      new_content = card.content
      content_changed = false

      apply_to_content.each do |i|
        plural, wrong_sing, correct_sing = corrections[i]
        if card.content =~ wrong_sing
          content_changed = true
          new_content = new_content.gsub(wrong_sing, correct_sing)
        end
      end
      if content_changed
        card.update_attributes! :content=>new_content
      end
    end
  end
end
