format :html do
  
  watch_perms = lambda { |r| Account.signed_in? && !r.card.new_card? }
  view :watch, :tags=>[:unknown_ok, :no_wrap_comments], :denial=>:blank, :perms=>watch_perms do |args|
    
    wrap args do
      if card.watching_type?
        watching_type_cards
      else
        link_args = if card.watching?
          ["following", :off, "stop sending emails about changes to #{card.cardname}", { :hover_content=> 'unfollow' } ]
        else
          ["follow", :on, "send emails about changes to #{card.cardname}" ]
        end
        watch_link *link_args
      end
    end
  end

  def watching_type_cards
    %{<div class="faint">(following)</div>} #yuck
  end

  def watch_link text, toggle, title, extra={}
    link_to "#{text}", path(:action=>:watch, :toggle=>toggle), 
      {:class=>"watch-toggle watch-toggle-#{toggle} slotter", :title=>title, :remote=>true, :method=>'post'}.merge(extra)
  end
  
end


event :record_followers, :before=>:store, :on=>:delete do
  # find before, because in case of deleted cards all the data is gone!

  @trunk_watcher_watched_pairs = trunk_watcher_watched_pairs
  @watcher_watched_pairs = watcher_watched_pairs
end

event :notify_followers, :after=>:extend do
  begin
    return false if Card.record_timestamps==false or Wagn.config.send_emails==false
    # userstamps and timestamps are turned off in cases like updating read_rules that are automated and
    # generally not of enough interest to warrant notification
  
    action = "#{@action}d"
  
    @trunk_watcher_watched_pairs ||= trunk_watcher_watched_pairs
    @watcher_watched_pairs ||= watcher_watched_pairs
    
    @watcher_watched_pairs.reject {|p| @trunk_watcher_watched_pairs.map(&:first).include? p.first }.each do |watcher, watched|
      watcher and mail = Mailer.change_notice( watcher, self, action, watched.to_s, nested_notifications ) and mail.deliver
    end
  
    if @supercard
      @supercard.nested_notifications ||= []
      @supercard.nested_notifications << [ name, action ]
    else
      @trunk_watcher_watched_pairs.each do |watcher, watched|
        next if watcher.nil?
        Mailer.change_notice( watcher, self.left, 'updated', watched.to_s, [[name, action]], self ).send_if :deliver
      end
    end
  rescue Exception=>e  #this error handling should apply to all extend callback exceptions
    Airbrake.notify e if Airbrake.configuration.api_key
    Rails.logger.info "\nController exception: #{e.message}"
    Rails.logger.debug "BT: #{e.backtrace*"\n"}"
  end
end

attr_accessor :nested_notifications

def trunk_watcher_watched_pairs
  # do the watchers lookup before the includer test since it's faster.
  if cardname.junction?
    tcard = Card[tname=cardname.trunk_name]
    tcard and pairs = tcard.watcher_watched_pairs
    #fixme - includers not working on structured cards, so this is commented for now
    return pairs if !pairs.nil? #and includers.map(&:key).member?(tname.key)
  end
  []
end

def watching_type?; watcher_pairs(false, :type).member? Account.current_id end
def watching?;      watcher_pairs(false).       member? Account.current_id end

def watchers
  watcher_watched_pairs false
end

def watcher_watched_pairs pairs=true
  watcher_pairs pairs, :name, whash = {}
  watcher_pairs pairs, :type, whash
end

def watcher_pairs pairs=true, kind=:name, hash={}
  #warn "wp #{inspect} P:#{pairs}, k:#{kind}, uid:#{Account.current_id} #{hash.inspect}, OI:#{hash.object_id}"

  wname, rc = (kind == :type) ?
       [ self.type_name, self.type_card.fetch(:trait=>:watchers) ] :
       [ self.cardname,  fetch(:trait=>:watchers) ]

  !rc.nil? and hash = rc.item_cards.inject( hash ) { |h, watcher| h[watcher.id] ||= wname; h } 

  if hash.any?
    #warn "wp #{pairs}, #{kind}, #{hash.inspect}"
    if pairs
      hash.each.reject {|i,wname| i == Account.current_id }.map {|i,wname| [ i, wname ] }
    else
      hash.keys
    end

  else [] 
  end
  #warn "wp r:#{r}"; r
end
