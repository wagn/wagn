event :update_ignoramuses_after_following_changed, :after=>:store, :changed=>:db_content do #when => proc { |c| c.db_content_changed?  } do
  new_content = db_content
  db_content = db_content_was
  item_cards.each do |item|
    item.drop_ignoramus self
  end
  db_content = new_content
  item_cards.each do |item|
    item.add_ignoramus self
  end
end