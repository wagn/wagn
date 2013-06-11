event :notify_followers, :after=>:extend do
  begin
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
  
    #warn "send note #{inspect}, #{action}, #{watcher_watched_pairs.inspect}"
    @trunk_watcher_watched_pairs = trunk_watcher_watched_pairs
    #warn "send note #{inspect}, #{action}, #{@trunk_watcher_watched_pairs.inspect}"
    @trunk_watchers = @trunk_watcher_watched_pairs.map(&:first)
  
    #Rails.logger.warn "send notice #{action}, #{inspect} TW:#{@trunk_watchers.inspect}"
  
    watcher_watched_pairs.reject {|p| @trunk_watchers.include?(p.first) }.each do |watcher, watched|
      #warn "wtch: Mailer.change_notice( #{watcher.inspect}, #{self.inspect}, #{action.inspect}, #{watched.inspect}, #{nested_notifications.inspect}"
      watcher and mail = Mailer.change_notice( watcher, self, action,
                      watched.to_s, nested_notifications ) and mail.deliver
    end
  
    if nested_edit
      nested_edit.nested_notifications ||= []
      nested_edit.nested_notifications << [ name, action ]
    else
      @trunk_watcher_watched_pairs.each do |watcher, watched|
        #warn "wp tw #{watcher.inspect}, #{watched.inspect}"
        next if watcher.nil?
        Mailer.change_notice( watcher, self.left, 'updated', watched.to_s, [[name, action]], self ).send_if :deliver
      end
    end
  rescue Exception=>e
    Airbrake.notify e if Airbrake.configuration.api_key
    Rails.logger.info "\nController exception: #{e.message}"
    Rails.logger.debug "BT: #{e.backtrace*"\n"}"
  end
end