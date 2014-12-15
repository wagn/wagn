card_accessor :followers

FOLLOW_CACHE_KEY = 'FOLLOW'

def label
  name
end

def follow_label
  name
end

def follow_option_card index
  if index and index < Card::FollowOption.names.size
    Card[Card::FollowOption.names[index]]
  end
end

def special_follow_option? name
  card = Card.fetch(name) and codename = card.codename and Card::FollowOption.names.include? codename.to_sym
end

def followers_of card=nil  # the argument is for compatibility reasons, needed for the special follow options
  if type_id == Card::SetID
    follower_ids.map { |id| Card.find(id) }
  else
    Card::Set::All::Notify::FollowerStash.new(self).followers
  end
end

def follower_ids
  @follower_ids ||= Follow.cache[follow_key] || []
end

def followed_by? user
  follower_ids.include? user.id
end


def add_follower user
  if not followed_by? user
    follower_ids << user.id
  end
  save_followers follower_ids
end

def drop_follower user
  follower_ids.delete(user.id)
  save_followers follower_ids
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

def related_follow_option_cards
  # refers to sets that users may follow from the current card
  @related_follow_option_cards ||= begin
    sets = set_names
    sets.pop unless codename == 'all' # get rid of *all set
    sets << "#{name}+*type" if known? && type_id==Card::CardtypeID
    sets << "#{name}+*right" if known? && cardname.simple?
    Card::FollowOption.names.each do |name|
      if Card[name].applies?(Auth.current, self)
        sets << name
      end
    end
    sets.map { |name| Card.fetch name }
  end
end

def all_follow_option_cards
  sets = set_names
  sets += Card::FollowOption.names
  sets.map { |name| Card.fetch name }
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
    wrap(args) do
      if card.type_id == CardtypeID
        follow_link Card.fetch("#{card.name}+*type"), 'all', :follow
      else
        follow_link Card.fetch("#{card.name}+*self"), '', :follow
      end
    end
  end

  view :follow_menu, :tags=>:unknown_ok do |args|
    follow_links = []
    card.related_follow_option_cards.size.times do |index|
      follow_links << render_follow_menu_item( :follow_menu_index => index )
    end
    follow_links.compact.map do |link|
      { :raw => wrap(args) {link} }
    end <<  { :raw => more_follow_options_link }
  end

  view :follow_menu_item do |args|
    index = args[:follow_menu_index] || (Env.params['follow_menu_index'] and Env.params['follow_menu_index'].to_i)
    if index and option_card = card.related_follow_option_cards[index] and option_card.followed?
      wrap(args) { follow_link(option_card) }
    else
      ''
    end
  end

  def more_follow_options_link
    path_options = {:card=>card, :view=>:follow_options }
    html_options = {:class=>"slotter", :remote=>true}
    link_to "advanced...", path(path_options), html_options
  end

  def follow_link index, link_label=nil, success_view=:follow_menu_item
    follow_option_card = if Integer===index
        card.related_follow_option_cards[index]
      else
        index
      end
    return '' unless follow_option_card

    toggle       = follow_option_card.followed? ? :off : :on
    label        = if follow_option_card.respond_to? :label
                      follow_option_card.label[0..0].downcase + follow_option_card.label[1..-1]
                   else
                      ''
                   end
    following    = Auth.current.fetch :trait=>:following, :new=>{:type=>:pointer}
    path_options = {:card=>following, :action=>:update, :follow_menu_index=>index,
                    :success=>{:id=>card.name, :view=>success_view} }
    html_options = {:class=>"watch-toggle watch-toggle-#{toggle} slotter", :remote=>true, :method=>'post'}

    link_label ||= " #{label}"
    case toggle
    when :off
      text                         = "following#{link_label}"
      path_options[:drop_item]     = follow_option_card.cardname.url_key
      html_options[:title]         = "stop sending emails about changes to #{label}"
      html_options[:hover_content] = "unfollow#{link_label}"
    when :on
      text                         = "follow#{link_label}"
      path_options[:add_item]      = follow_option_card.cardname.url_key
      html_options[:title]         = "send emails about changes to #{label}"
    end
    link_to text, path(path_options), html_options
  end
end


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

