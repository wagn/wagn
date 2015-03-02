card_accessor :followers

FOLLOWER_IDS_CACHE_KEY = 'FOLLOWER_IDS'

event :cache_expired_because_of_new_set, :before=>:store, :on=>:create, :when=>proc { |c| c.type_id == Card::SetID } do
  Card.follow_caches_expired
end

event :cache_expired_because_of_type_change, :before=>:store, :changed=>:type_id do  #FIXME expire (also?) after save
  Card.follow_caches_expired
end

event :cache_expired_because_of_name_change, :before=>:store, :changed=>:name do
  Card.follow_caches_expired
end

event :cache_expired_because_of_new_user_rule, :before=>:extend, :when=>proc { |c| c.follow_rule_card? }  do
  Card.follow_caches_expired
end



format :html do
  view :follow_menu_link, :tags=>[:unknown_ok, :no_wrap_comments], :denial=>:blank, :perms=>:none do |args|
    wrap(args) do
      render_follow_link( args.merge(:label=>'',:main_menu=>true) )
    end
  end
  
  view :follow_submenu_link, :tags=>[:unknown_ok, :no_wrap_comments], :denial=>:blank, :perms=>:none do |args|
    wrap(args) do
      render_follow_link args.merge(:hover=>true)
    end
  end
 
  view :follow_link, :tags=>[:unknown_ok, :no_wrap_comments], :denial=>:blank, :perms=>:none do |args|   
    success_view = (args[:main_menu] ? :follow_menu_link : :follow_submenu_link)
    path_options = { 
                      :action=>:update,
                      :success=>{:id=>card.name, :view=>success_view} 
                   }
    html_options = {  
                      :class=>"watch-toggle watch-toggle-#{args[:toggle]} slotter", 
                      :remote=>true, 
                      :method=>'post'
                   }

    case args[:toggle]
    when :off
      path_options['card[content]']= '[[*never]]'
      html_options[:title]         = "stop sending emails about changes to #{args[:label]}"
      if args[:hover]
        html_options[:hover_content] = "unfollow #{args[:label]}" 
        html_options[:text]          = "following #{args[:label]}"
      else
        html_options[:text]          = "unfollow #{args[:label]}"
      end
    when :on
      path_options['card[content]']= '[[*always]]'
      html_options[:title]         = "send emails about changes to #{args[:label]}"
      html_options[:text]          = "follow #{args[:label]}"
    end
    if html_options[:text].size > 30
      html_options[:text] = html_options[:text][0..27] + '...'
    end
    if args[:main_menu]
      html_options[:text] = '<span class="ui-menu-icon ui-icon ui-icon-carat-1-w"></span>' + html_options[:text]
      # html_options[:text] =  glyphicon('menu-left') + html_options[:text]    #TODO use glyphicons instead of ui-cons
    end
    follow_rule_name = card.default_follow_set_card.follow_rule_name Auth.current.name
    card_link follow_rule_name, html_options.merge(:path_opts=>path_options) 
  end
  
  def default_follow_link_args args
    args[:toggle] ||=  card.followed? ? :off : :on
    args[:label]  ||=  card.follow_label
  end
  
end


def follow_label
  name
end

def followers
  follower_ids.map do |id|
    Card.fetch(id)
  end
end

def follower_names
  followers.map(&:name)
end


def follow_rule_card?
  is_user_rule? && rule_setting_name == '*follow'
end

def follow_option?
  codename && Card::FollowOption.codenames.include?(codename.to_sym) 
end

# used for the follow menu
# overwritten in type/set.rb and type/cardtype.rb
# for sets and cardtypes it doesn't check whether the users is following the card itself
# instead it checks whether he is following the complete set
def followed_by? user_id
  if follow_rule_applies? user_id
    return true
  end
  left_card = left
  while left_card
    if left_card.followed_field?(self) && left_card.follow_rule_applies?(user_id)
      return true
    end
    left_card = left_card.left
  end
  return false
end

def followed?
  followed_by? Auth.current_id 
end


def follow_rule_applies? user_id
  if (follow_rule_card=rule_card(:follow, :user_id=>user_id))
    follow_rule_card.item_cards.each do |item_card|
      if item_card.respond_to?(:applies_to?) and item_card.applies_to? self, user_id
         return item_card
      end
    end
  end 
  return false
end


# the set card to be followed if you want to follow changes of card
def default_follow_set_card
  Card.fetch("#{name}+*self")
end


# returns true if according to the follow_field_rule followers of self also 
# follow changes of field_card
def followed_field? field_card
  (follow_field_rule = rule_card(:follow_fields)) || follow_field_rule.item_names.find do |item|
     item.to_name.key == field_card.key ||  (item.to_name.key == Card[:includes].key && included_card_ids.include?(field_card.id) )
  end
end

def follower_ids
  @follower_ids = read_follower_ids_cache || begin
    result = direct_follower_ids
    left_card = left
    while left_card
      if left_card.followed_field? self
        result += left_card.direct_follower_ids
      end
      left_card = left_card.left
    end
    write_follower_ids_cache result
    result
  end
end


def direct_followers
  direct_follower_ids.map do |id|
    Card.fetch(id)
  end
end

# all ids of users that follow this card because of a follow rule that applies to this card
# doesn't include users that follow this card because they are following parent cards or other cards that include this card
def direct_follower_ids args={}  
  result = ::Set.new
  set_names.each do |set_name| 
    set_card = Card.fetch(set_name)
    set_card.all_user_ids_with_rule_for(:follow).each do |user_id|
      if (!result.include? user_id) and self.follow_rule_applies?(user_id)
        result << user_id
      end
    end
  end
  result
end

def all_direct_follower_ids_with_reason
  visited = ::Set.new
  set_names.each do |set_name| 
    set_card = Card.fetch(set_name)
    set_card.all_user_ids_with_rule_for(:follow).each do |user_id|
      if (!visited.include?(user_id)) && (follow_option_card = self.follow_rule_applies?(user_id))
        visited << user_id
        yield(user_id, :set_card=>set_card, :option_card=>follow_option_card)
      end
    end
  end
end

#~~~~~ cache methods

def write_follower_ids_cache user_ids
  hash = Card.follower_ids_cache
  hash[id] = user_ids
  Card.write_follower_ids_cache hash
end

def read_follower_ids_cache
  Card.follower_ids_cache[id]
end

module ClassMethods

  def follow_caches_expired
    Card.clear_follower_ids_cache
    Card.clear_user_rule_cache
  end

  def follower_ids_cache
    Card.cache.read(FOLLOWER_IDS_CACHE_KEY) || {}
  end
  
  def write_follower_ids_cache hash
    Card.cache.write FOLLOWER_IDS_CACHE_KEY, hash
  end

  def clear_follower_ids_cache
    Card.cache.write FOLLOWER_IDS_CACHE_KEY, nil
  end

end

