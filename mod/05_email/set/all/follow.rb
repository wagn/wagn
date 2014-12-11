card_accessor :followers

FOLLOW_CACHE_KEY = 'FOLLOW'

FOLLOW_OPTIONS =  [ {
      :name => 'content I created',
      :applies? => Proc.new do |user, card|
          card.creator and card.creator.type_id == Card::UserID and card.creator == user 
        end,
      :followers => Proc.new do |card, &block|
        card.creator and card.creator.type_id == Card::UserID and card.creator.following? Card[:created_by_me].cardname
          block.call card.creator, Card[:created_by_me].name
        end
    },
    {
      :name => 'content I edited',
      :applies? => Proc.new do |user, card|
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
  index < FOLLOW_OPTIONS.size and FOLLOW_OPTIONS[index][:applies?].call(check_follower, self)
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


def followers
  if type_id == Card::SetID
    Follow.cache[follow_key] || ::Set.new
  else
    Card::Set::All::Notify::FollowerStash.new(self).followers
  end
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

def save_followers new_followers
  hash = Follow.cache
  hash[follow_key] = new_followers
  Follow.store_cache hash
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


format :html do
  watch_perms = lambda { |r| Auth.signed_in? && !r.card.new_card? }  # how was this used to be used?
  
  view :follow, :tags=>[:unknown_ok, :no_wrap_comments], :denial=>:blank, :perms=>:none do |args|
    card.followed? ? 'following' : 'follow'
  end
  
  view :follow_menu, :tags=>:unknown_ok do |args|
    links = []
    (card.related_sets.size + FOLLOW_OPTIONS.size).times do |index|
      link << render_follow_menu( :follow_menu_item => index )
    end
    links.compact.map do |link|
      { :raw => link }
    end
  end

  view :follow_menu_item do |args|
    index = args[:follow_menu_index] || (Env.params['follow_menu_index'] and Env.params['follow_menu_index'].to_i)
    if index
      link_args = if index < card.related_sets.size
        name, label = card.related_sets[index]
        follow_link_args name, label, index
      elsif (index-card.related_sets.size) < FOLLOW_OPTIONS.size
        special_follow_link_args index-card.related_sets.size, index
      end
      
      if link_args
        wrap(args) do 
          follow_link(*link_args)
        end
      end
    else
      ''
    end
  end
  
  
  def build_link toggle, followed_set_card, label, index
    return '' unless followed_set_card
    
    following = Auth.current.fetch :trait=>:following, :new=>{:type=>:pointer}
    path_hash = {:card=>following, :action=>:update, :follow_menu_index=>index,
                 :success=>{:id=>card.name, :view=>:follow_menu_item} }
    options   = {:class=>"watch-toggle watch-toggle-#{toggle} slotter", :remote=>true, :method=>'post'}
    
    case toggle
    when :off 
      text                    = "following #{label}"
      path_hash[:drop_item]   = followed_set_card.cardname.url_key
      options[:title]         = "stop sending emails about changes to #{label}"
      options[:hover_content] = "unfollow #{label}"
    when :on 
      text                    = "follow #{label}"
      path_hash[:add_item]    = followed_set_card.cardname.url_key
      options[:title]         = "send emails about changes to #{label}"
    end

    link_to text, path(path_hash), opts_hash
  end
  
  def special_follow_link index, total_index
    name = FOLLOW_OPTIONS[index][:name]
    if card.special_followed?(index)
      build_link :off, Card.fetch(name), name, total_index
    elsif card.special_option_applies? index, Auth.current
      build_link :on, Card.fetch(name), name, total_index
    end
  end
    
  def follow_link_args name, label, index
    label = label[0..0].downcase + label[1..-1]
    set_card = Card.fetch(name)
    toggle = set_card.set_followed? ? :off : :on
    build_link toggle, set_card, label, index
  end
      
end


def set_followed?; Auth.current.fetch(:trait=>:following, :new=>{}).include_item? cardname end
def special_followed?(index); special_follower? index, Auth.current end
def followed?; followed_by? Auth.current end


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

