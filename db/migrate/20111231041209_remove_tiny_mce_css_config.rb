class RemoveTinyMceCssConfig < ActiveRecord::Migration
  def up
    User.as :wagbot do
      if card = Card['*tiny_mce']
        card = card.refresh
        card.content = card.content.sub /^content_css.*$/, ''
        card.save!
      end
    end
  end

  def down
  end
end
