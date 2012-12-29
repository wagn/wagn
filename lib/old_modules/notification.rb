module Notification
  module CardMethods
    def self.included(base)
      super
      base.class_eval { attr_accessor :nested_notifications }
    end

    def send_notifications
      return false if Card.record_timestamps==false || Wagn::Conf[:migration]
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
      #warn "send note #{inspect}, #{action}, #{trunk_watcher_watched_pairs.inspect}"
      @trunk_watchers = @trunk_watcher_watched_pairs.map(&:first)

      #Rails.logger.warn "send notice #{action}, #{inspect} TW:#{@trunk_watchers.inspect}"

      watcher_watched_pairs.reject {|p| @trunk_watchers.include?(p.first) }.each do |watcher, watched|
        #Rails.logger.warn "wtch: Mailer.change_notice( #{watcher.inspect}, #{self.inspect}, #{action.inspect}, #{watched.inspect}, #{nested_notifications.inspect}"
        watcher and mail = Mailer.change_notice( watcher, self, action,
                        watched.to_s, nested_notifications ) and mail.deliver
      end

      if nested_edit
        nested_edit.nested_notifications ||= []
        nested_edit.nested_notifications << [ name, action ]
      else
        @trunk_watcher_watched_pairs.compact.each do |watcher, watched|
          next unless watcher
          Mailer.change_notice( watcher, self.left, 'updated', watched.to_s, [[name, action]], self ).deliver
        end
      end
    rescue Exception=>e
      Airbrake.notify e if Airbrake.configuration.api_key
      Rails.logger.info "\nController exception: #{e.message}"
      Rails.logger.debug e.backtrace*"\n"
    end

    def trunk_watcher_watched_pairs
      # do the watchers lookup before the includer test since it's faster.
      if cardname.junction?
        #warn "trunk_watcher_pairs #{cardname}, #{cardname.trunk_name.inspect}, #{includers.inspect}"
        if tcard = Card[tname=cardname.trunk_name] and
          pairs = tcard.watcher_watched_pairs
          #warn "trunk_watcher_pairs TC:#{tcard.inspect}, #{tname}, P:#{pairs.inspect}, k:#{tname.key} member: pr:#{pairs}, I:#{includers.inspect} test:#{pairs.nil?} or #{includers.map(&:key).member?(tname.key)}"
          return pairs unless pairs.nil? or includers.map(&:key).member?(tname.key)
        end
        #warn "twatch empty ..."
      end
      []
    end

    def watching_type?; watcher_pairs(false, :type).member? Account.user_id end
    def watching?;      watcher_pairs(false).       member? Account.user_id end
    def watchers;       watcher_watched_pairs false                         end
    def watcher_watched_pairs pairs=true
      watcher_pairs( pairs, :name, whash = {} )
      watcher_pairs( pairs, :type, whash )
    end

    def watcher_pairs pairs=true, kind=:name, hash=nil
      #warn "wp #{pairs}, #{kind}, #{Account.user_id} #{hash.inspect}, OI:#{hash.object_id}"

      namep, rc = (kind == :type) ?  [lambda { self.type_name },
               (self.type_card.fetch(:trait=>:watchers))] :
            [lambda { self.cardname }, fetch(:trait=>:watchers)]

      if !rc.nil? and watcher_hash = rc.item_cards.
            inject( hash || {} ) { |h, watcher|
        h[watcher.id] = true; h } and
          watcher_hash.any?
                   
        #warn "wp #{pairs}, #{kind}, #{watcher_hash.inspect}"
        if pairs
          watcher_hash.keys.reject {|i| i == Account.user_id }.map {|i| [i, namep.call] }
        else
          watcher_hash.keys
        end

      else [] 
      end
    end
  end

  def self.init
    Card.send :include, CardMethods
  end
end

Notification.init



