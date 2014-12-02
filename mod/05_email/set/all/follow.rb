card_accessor :followed_by


def followers
  followers = fetch :trait=>:followed_by
  followers.format.render_raw
end

FOLLOW_KEY = 'FOLLOW'
FOLLOW_OPTIONS =  ['content I created', 'content I edited']

def toggle_subscription_for watcher
  following = watcher.fetch :trait=>:following, :new=>{:type=>:pointer}
  if following.items.include? card
    following.drop_item card.name
  else
    following.add_item card.name
  end
  following.save
end

def special_follow_option? name
 FOLLOW_OPTIONS.include? name
end

def update_follow_cache
  follow_cache = Hash.new { |hash,key| hash[key] = []}
  Card.search( :left_id=>UserID, :right=>{:codename=> "following"} ).each do |following_pointer|
    following_pointer.item_cards.each do |followed|
      if followed.type_id != SetID and !special_follow_option? followed.name
        self_set = followed.fetch(:trait=>:self)
        follow_cache[self_set.key] << following_pointer.left_id
      else
        follow_cache[followed.key] << following_pointer.left_id 
      end
    end
  end
  Card.cache.write FOLLOW_KEY, follow_cache
end

event :expired_follow_cache, :before=>:extend, :when => 
        proc { |c| c.name_changed? or (c.right and c.right.codename == :following and c.left_id == UserID)
  update_follow_cache
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
        [card,"following", :off, "stop sending emails about changes to #{follow_set_card(card).name}", { :hover_content=> 'unfollow' } ]
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
    when :off then path_hash[:drop_item] = card.follow_set_card(watched_card).cardname.url_key
    when :on  then path_hash[:add_item]  = card.follow_set_card(watched_card).cardname.url_key
    end

    link_to "#{text}", path(path_hash), 
      {:class=>"watch-toggle watch-toggle-#{toggle} slotter", :title=>title, :remote=>true, :method=>'post'}.merge(extra)
  end
  
end

# the set card to be followed if you want to follow changes of card
def follow_set_card card
  case card.type_code 
  when :cardtype
    card.fetch(:trait=>:type)
  when :set
    card
  else
    card.fetch(:trait=>:self)
  end
end


def  follow_options
  related_sets.map do |name,label| 
    { :follow_link=>"aefwaf" } #Card.fetch(name).format(:format=>:html).render_watch }
    # { :text=>"Follow #{label}",
#       :path_opts=>{:add_item=>name}
#}
  end
end

def type_watched?; Auth.current.fetch(:trait=>:following, :new=>{}).include_item? type_card.fetch(:trait=>:type).cardname end
def self_watched?; Auth.current.fetch(:trait=>:following, :new=>{}).include_item? fetch(:trait=>:self).cardname end
def set_watched?;  !(Auth.current.fetch(:trait=>:following, :new=>{}).item_names & set_names).empty? end




