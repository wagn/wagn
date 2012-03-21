module Notification
  module CardMethods
    def self.included(base)
      super
      base.class_eval { attr_accessor :nested_notifications }
    end

    def send_notifications
      return false if Card.record_userstamp==false
      # userstamps and timestamps are turned off in cases like updating read_rules that are automated and
      # generally not of enough interest to warrant notification

      action = case
        when trash;  'deleted'
        when @was_new_card; 'added'
        when nested_notifications; 'updated'
        when updated_at.to_s==current_revision.created_at.to_s;  'edited'
        else; 'updated'
      end

      @trunk_watcher_watched_pairs = trunk_watcher_watched_pairs
      @trunk_watchers = @trunk_watcher_watched_pairs.map(&:first)

      watcher_watched_pairs.reject {|p| @trunk_watchers.include?(p.first) }.each do |watcher, watched|
        watcher and mail = Mailer.change_notice( watcher, self, action,
                        watched, nested_notifications ) and mail.deliver
      end

      if nested_edit
        nested_edit.nested_notifications ||= []
        nested_edit.nested_notifications << [ name, action ]
      else
        @trunk_watcher_watched_pairs.compact.each do |watcher, watched|
          next unless watcher
          Mailer.change_notice( watcher, self.trunk, 'updated', watched, [[name, action]], self ).deliver
        end
      end
    end

    def trunk_watcher_watched_pairs
      # do the watchers lookup before the transcluder test since it's faster.
      if cardname.junction?
        #Rails.logger.debug "trunk_watcher_pairs #{name}, #{name.trunk_name.inspect}"
        if tcard = Card[tname=cardname.trunk_name] and
          pairs = tcard.watcher_watched_pairs and
          transcluders.map(&:key).member?(tname.to_key)
          return pairs
        end
      end
      []
    end

    def watchers() watcher_watched_pairs(false) end
    def watcher_watched_pairs(pairs=true)
      ( watcher_pairs(pairs) + watcher_pairs(pairs, :type) )
    end

    def watcher_pairs(pairs=true, kind=:name)
      cuid=Card.user_id
      namep, rc = (kind == :type) ?  [lambda { self.typename },
               (Card[self.type_id||Card::DefaultID].star_rule(:watchers))] :
            [lambda { self.cardname }, star_rule(:watchers)]
      watchers = rc.nil? ? [] : rc.item_cards.map(&:id) #.find_all{|i|i!=cuid}
      pairs ? watchers.map {|w| [w, namep.call] } : watchers
    end
  end

  def self.init
    Card.send :include, CardMethods
  end
end

Notification.init



