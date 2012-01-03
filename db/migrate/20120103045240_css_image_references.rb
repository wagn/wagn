class CssImageReferences < ActiveRecord::Migration
  def up
    User.as :wagbot do
      if card = Card['*css'] and card.content =~ /\/images/
        card = card.refresh
        card.content = card.content.gsub /url\(\s*\/images/, 'url(assets'
        card.save!
      end
    end
  end

  def down
  end
end
