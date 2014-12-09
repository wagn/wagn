card_accessor :followers

FOLLOW_CACHE_KEY = 'FOLLOW'


FOLLOW_OPTIONS =  [ {
      :name => 'content I created',
      :condition => Proc.new do |user, card|
          card.creator and card.creator.type_id == Card::UserID and card.creator == user 
        end,
      :followers => Proc.new do |card, &block|
        card.creator and card.creator.type_id == Card::UserID and card.creator.following? Card[:created_by_me].cardname
          block.call card.creator, Card[:created_by_me].name
        end
    },
    {
      :name => 'content I edited',
      :condition => Proc.new do |user, card|
          Card.search(:editor_of=>card.name).include? user
        end,
      :followers => Proc.new do |card, &block|
          Card.search(:editor_of=>card.name).each do |editor|
            if editor and editor.type_id == Card::UserID and editor.following? Card[:edited_by_me].cardname
              block.call editor, Card[:edited_by_me].name
            end
          end
        end
    }
  ]



def special_followers index=nil, &block
  if index and index < FOLLOW_OPTIONS.size
    FOLLOW_OPTIONS[index][:followers].call(self, &block) 
  else
    FOLLOW_OPTIONS.each do |hash|
      hash[:followers].call(self, &block)
    end
  end
end

def special_option_applies? index, check_follower
  index < FOLLOW_OPTIONS.size and FOLLOW_OPTIONS[index][:condition].call(check_follower, self)
end

def special_follower? index, check_follower
  special_followers(index) do |follower, name|
    return true if check_follower == follower
  end
  return false
end

def special_follow_option? name
 FOLLOW_OPTIONS.map{|h| h[:name]}.include? name
end

def self.cache_expired
  Card.cache.write FOLLOW_CACHE_KEY, nil
end

def self.cache
  Card.cache.read(FOLLOW_CACHE_KEY) || refresh_cached_sets
end

def self.store_cache hash
  Card.cache.write FOLLOW_CACHE_KEY, hash
  hash
end

def self.refresh_cached_sets
  follow_cache = {}
  Card.search( :left=>{:type_id=>Card::UserID}, :right=>{:codename=> "following"} ).each do |following_pointer|
    following_pointer.item_cards.each do |followed|
      key = followed.follow_key
      if follow_cache[key]
        follow_cache[key] << following_pointer.left_id
      else
        follow_cache[key] = ::Set.new [following_pointer.left_id]
      end
    end
  end
  Follow.store_cache follow_cache
end


def followers
  #@followers ||= cached_followers
  cached_followers
end

def cached_followers
  if type_id == Card::SetID
    Follow.cache[follow_key] || ::Set.new
  else
    Card::Set::All::Notify::FollowerStash.new(self).followers
  end
end

def save_followers new_followers
  hash = Follow.cache
  hash[follow_key] = new_followers
  Follow.store_cache hash
end

def followed_by? user
  followers.include? user.id
end


def add_follower user
  if not followed_by? user
    followers << user.id
  end
  save_followers followers
end

def drop_follower user
  followers.delete(user.id)
  save_followers followers
end




# the set card to be followed if you want to follow changes of card
def follow_set_card
  if special_follow_option? name
    self
  else
    case type_code 
    when :cardtype
      fetch(:trait=>:type)
    when :set
      self
    else
      fetch(:trait=>:self)
    end
  end
end

def follow_set
  follow_set_card.name
end

def follow_key
  follow_set_card.key
end

event :cache_expired_because_of_new_set, :before=>:extend, :on=>:create, :when=> proc { |c| c.type_id == Card::SetID } do
  Follow.cache_expired
end

event :cache_expired_because_of_type_change, :before=>:extend, :changed=>:type_id do
  Follow.cache_expired
end

event :cache_expired_because_of_name_change, :before=>:extend, :changed=>:name do
  Follow.cache_expired
end

def toggle_subscription_for watcher
  following = watcher.fetch :trait=>:following, :new=>{:type=>:pointer}
  if following.items.include? card
    following.drop_item card.name
  else
    following.add_item card.name
  end
  following.save
end

format :html do
  watch_perms = lambda { |r| Auth.signed_in? && !r.card.new_card? }
  
  view :follow, :tags=>[:unknown_ok, :no_wrap_comments], :denial=>:blank, :perms=>:none do |args|
    'follow'
    # wrap args do
    #   link_args = if card.self_watched?
    #       [card,"following", :off, "stop sending emails about changes to #{card.name}", { :hover_content=> 'unfollow' } ]
    #     elsif card.type_watched?
    #       [card.type_card, "(following)", :off, "stop sending emails about changes to #{card.type_name} cards", { :hover_content=> 'unfollow' } ]
    #     elsif card.set_watched?
    #       [card,"following", :off, "stop sending emails about changes to #{card.follow_set_card.name}", { :hover_content=> 'unfollow' } ]
    #     else
    #       [card,"follow", :on, "send emails about changes to #{card.name}" ]
    #     end
    #   watch_link *link_args
    # end
  end
  
  view :follow_menu, :tags=>:unknown_ok do |args|
    index = 0
    link_args = []
    card.related_sets.each do |name,label|
      link_args << follow_link_args( name, label, index )
      index += 1
    end
    FOLLOW_OPTIONS.each_index do |opt_index|
      if next_args = special_follow_link_args( opt_index, index )
        link_args << next_args
        index += 1
      end
    end
#    binding.pry
    link_args.compact.map do |link_arg|
      { :raw => wrap(args) do follow_link(*link_arg) end }
    end
  end

  view :follow_menu_item do |args|
    if Env.params['follow_menu_index'] and index = Env.params['follow_menu_index'].to_i
      link_args = if index < card.related_sets.size
        name, label = card.related_sets[index]
        follow_link_args name, label, index
      elsif (index-card.related_sets.size) < FOLLOW_OPTIONS.size
        special_follow_link_args index-card.related_sets.size, index
      end
    else
      ''
    end
  end
  
  def follow_link followed_set_card, text, toggle, title, index, extra={}
    return '' unless followed_set_card
    
    following = Auth.current.fetch :trait=>:following, :new=>{:type=>:pointer}
    path_hash = {:card=>following, :action=>:update, :toggle=>toggle, :follow_menu_index=>index,
                 :success=>{:id=>card.name, :view=>:follow_menu_item} }
    case toggle
    when :off then path_hash[:drop_item] = followed_set_card.cardname.url_key
    when :on  then path_hash[:add_item]  = followed_set_card.cardname.url_key
    end

    link_to "#{text}", path(path_hash), 
      {:class=>"watch-toggle watch-toggle-#{toggle} slotter", :title=>title, :remote=>true, :method=>'post'}.merge(extra)
  end
  
  def  special_follow_link_args index, total_index
    name = FOLLOW_OPTIONS[index][:name]
    if card.special_follower? index, Auth.current
      [Card.fetch(name), "following #{name}", :off,  "stop sending emails about changes to #{name}", total_index, { :hover_content=> "unfollow #{name}" }]
    elsif card.special_option_applies? index, Auth.current
      [Card.fetch(name), "follow #{name}", :on,  "send emails about changes to #{name}", total_index]
    end
  end
    
  def follow_link_args name, label, index
    label = label[0..0].downcase + label[1..-1]
    set_card = Card.fetch(name)
    if set_card.watched?
      [set_card, "following #{label}", :off,  "stop sending emails about changes to #{label}", index, { :hover_content=> "unfollow #{label}" } ]
    else
      [set_card, "follow #{label}", :on, "send emails about changes to #{label}", index]
    end
  end
      
end




def watched?;  Auth.current.fetch(:trait=>:following, :new=>{}).include_item? cardname end
def type_watched?; Auth.current.fetch(:trait=>:following, :new=>{}).include_item? type_card.fetch(:trait=>:type).cardname end
def self_watched?; Auth.current.fetch(:trait=>:following, :new=>{}).include_item? fetch(:trait=>:self).cardname end
def set_watched?;  !(Auth.current.fetch(:trait=>:following, :new=>{}).item_names & set_names).empty? end




