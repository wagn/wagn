class ChangeEditedToEditorOf < ActiveRecord::Migration
  def up
    User.as :wagbot do
      Card.search( :type=>'Search' ).each do |card|
        if card.content =~ /\"edited\"/
          card = card.refresh
          card.content = card.content.gsub '"edited"', '"editor_of"'
          card.save!
        end
      end
    end
  end

  def down
    User.as :wagbot do
      Card.search( :type=>'Search' ).each do |card|
        if card.content =~ /\"editor_of\"/
          card = card.refresh
          card.content = card.content.gsub '"editor_of"', '"edited"'
          card.save!
        end
      end
    end
  end
end
