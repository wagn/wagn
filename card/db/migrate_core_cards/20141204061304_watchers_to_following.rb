# -*- encoding : utf-8 -*-

class WatchersToFollowing < Card::CoreMigration
  def up
    follower_hash = Hash.new { |h, v| h[v] = [] }

    # NOTE: this migration must find cards in the trash, because the original (1.14.0) migration attempt
    # did not successfully migration to the +*following card but did successfully delete +*watchers cards.
    # Therefore cards migrated using 1.14.0 or 1.14.1 will not have the correct migrations

    if watcher_card = Card.find_by_key("*watcher")
      Card.find_by_sql("select * from cards where right_id = #{watcher_card.id}").each do |card|
        card.include_set_modules

        next unless watched = card.left
        card.item_names.each do |user_name|
          follower_hash[user_name] << watched.name
        end
      end

      follower_hash.each do |user, items|
        next unless (card = Card.fetch(user)) && card.account
        following = card.fetch trait: "following",  new: { type_code: :pointer }
        items.each { |item| following.add_item item }
        following.save!
      end
    end

    if watchers = Card[:watchers]
      watchers.update_attributes codename: nil
      watchers.delete!
    end
  end
end
