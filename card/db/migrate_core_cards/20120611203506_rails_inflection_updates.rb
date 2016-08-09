# -*- encoding : utf-8 -*-
class RailsInflectionUpdates < Card::CoreMigration
  def word ar
    [/(?<=\W|_|^)#{ar[0]}(?=\W|_|$)/i, /(?<=\W|_|^)#{ar[1]}(?=\W|_|$)/i, ar[2]]
  end

  def word_end ar
    [/#{ar[0]}(?=\W|_|$)/i, /#{ar[1]}(?=\W|_|$)/i, ar[2]]
  end

  def keep_the_s word
    ["#{word}s", word, "#{word}s"]
  end

  def unless_name_collision card
    if (twin = Card.find_by_key(card.cardname.key)) && twin.id != card.id
      if twin.trash
        twin.destroy
        yield
      elsif !card.trash
        raise Card::Oops.new("Your deck has two different cards with names '#{card.name}' and '#{twin.name}'. After this update it's no longer possible to differentiate between those two names. Please rename or delete one of the two cards and run the update again.")
      end
    else
      yield
    end
  end

  def up
    card_names = Card.pluck(:name)
    apply_to_content = ::Set.new
    corrections = [
      # plural,     wrong singular,  correct singular
      word(['(\w+)lice',  '(\w+)louse',    '\1lice']),
      word(['(\w+)mice',  '(\w+)mouse',    '\1mice']),
      word_end(%w(kine cow kine)),
      word(keep_the_s("analysi")),
      word(keep_the_s("axi"))
    ]
    %w(statu crisi alia bu octopu viru analysi basi diagnosi parenthesi prognosi synopsi thesi).each do |word|
      corrections << word_end(keep_the_s(word))
    end

    corrections.each_with_index do |cors, i|
      plural, wrong_sing, correct_sing = cors

      card_names.reject! do |name|  # change a name only once
        next unless name =~ plural
        # can't use fetch, because it uses the wrong key
        # find_by_name is case-insensitve and finds the wrong cards for camel case names
        card = Card.where(name: name).find { |card| card.name == name }

        unless_name_collision(card) do
          apply_to_content << i
          new_key = name.to_name.key
          if card.key == new_key
            # noop.  probably means this was already migrated?
          elsif Card.find_by_key new_key
            puts "Could not update #{name}. Key '#{new_key}' already exists."
          else
            card.update_attributes! key: new_key
          end
        end
      end
    end

    cards_with_css = Card.search type: %w(in html css scss)
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
      card.update_attributes! content: new_content if content_changed
    end
  end
end
