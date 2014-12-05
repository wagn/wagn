card_accessor :followers

FOLLOW_CACHE_KEY = 'FOLLOW'

FOLLOW_OPTIONS =  ['content I created', 'content I edited']
def special_followers 
  Card.search(:editor_of=>name).each do |editor|
    if editor.type_id == UserID and editor.following? Card[:edited_by_me].cardname
      yield editor, Card[:edited_by_me].name
    end
  end
  if creator.type_id == UserID and creator.following? Card[:created_by_me].cardname
    yield creator, Card[:created_by_me].name
  end
end


def self.cache
  Card.cache.read(FOLLOW_CACHE_KEY) || update_cache
end

def self.store_cache hash
  Card.cache.write FOLLOW_CACHE_KEY, hash
  hash
end

def self.update_cache
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
  @followers ||= ( Follow.cache[follow_key] || ::Set.new() )
end

def save_followers 
  hash = Follow.cache
  hash[follow_key] = followers
  Follow.store_cache hash
end

def followed_by? user
  followers.include? user.id
end


def add_follower user
  if not followed_by? user
    followers << user.id
  end
  save_followers
end

def drop_follower user
  followers.delete(user.id)
  save_followers
end


def special_follow_option? name
 FOLLOW_OPTIONS.include? name
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
  follow_set
end



event :expired_follower_cache, :before=>:extend, :changed=>:name do
  Follow.update_cache
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
  
  view :watch, :tags=>[:unknown_ok, :no_wrap_comments], :denial=>:blank, :perms=>:none do |args|
    wrap args do
      link_args = if card.self_watched?
          [card,"following", :off, "stop sending emails about changes to #{card.name}", { :hover_content=> 'unfollow' } ]
        elsif card.type_watched?
          [card.type_card, "(following)", :off, "stop sending emails about changes to #{card.type_name} cards", { :hover_content=> 'unfollow' } ]
        elsif card.set_watched?
          [card,"following", :off, "stop sending emails about changes to #{card.follow_set_card.name}", { :hover_content=> 'unfollow' } ]
        else
          [card,"follow", :on, "send emails about changes to #{card.name}" ]
        end
      watch_link *link_args
    end
  end


  def watch_link watched_card, text, toggle, title, extra={}
    return '' unless watched_card
    
    following = Auth.current.fetch :trait=>:following, :new=>{:type=>:pointer}
    path_hash = {:card=>following, :action=>:update, :toggle=>toggle, 
                 :success=>{:id=>card.name, :view=>:watch} }
    case toggle
    when :off then path_hash[:drop_item] = watched_card.follow_set_card.cardname.url_key
    when :on  then path_hash[:add_item]  = watched_card.follow_set_card.cardname.url_key
    end

    link_to "#{text}", path(path_hash), 
      {:class=>"watch-toggle watch-toggle-#{toggle} slotter", :title=>title, :remote=>true, :method=>'post'}.merge(extra)
  end
  
end




def  follow_options
#   related_sets.map do |name,label|
#     { :follow_link=>"aefwaf" } #Card.fetch(name).format(:format=>:html).render_watch }
#     # { :text=>"Follow #{label}",
# #       :path_opts=>{:add_item=>name}
# #}
#   end
end

def type_watched?; Auth.current.fetch(:trait=>:following, :new=>{}).include_item? type_card.fetch(:trait=>:type).cardname end
def self_watched?; Auth.current.fetch(:trait=>:following, :new=>{}).include_item? fetch(:trait=>:self).cardname end
def set_watched?;  !(Auth.current.fetch(:trait=>:following, :new=>{}).item_names & set_names).empty? end




