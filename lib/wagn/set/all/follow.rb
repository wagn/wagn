# -*- encoding : utf-8 -*-

class Card
  attr_accessor :nested_notifications

  def trunk_watcher_watched_pairs
    # do the watchers lookup before the includer test since it's faster.
    if cardname.junction?
      #warn "trunk_watcher_pairs #{cardname}, #{cardname.trunk_name.inspect}, #{includers.inspect}"
      tcard = Card[tname=cardname.trunk_name]
      tcard and pairs = tcard.watcher_watched_pairs
        #warn "trunk_watcher_pairs TC:#{tcard.inspect}, #{tname}, P:#{pairs.inspect}, k:#{tname.key} member: pr:#{!pairs.nil?}, and I:#{includers.map(&:key).member?(tname.key)}"
      return pairs if !pairs.nil? and includers.map(&:key).member?(tname.key)
      #warn "twatch empty ..."
    end
    []
  end

  def watching_type?; watcher_pairs(false, :type).member? Account.current_id end
  def watching?;      watcher_pairs(false).       member? Account.current_id end
  def watchers;       watcher_watched_pairs false                         end
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
end