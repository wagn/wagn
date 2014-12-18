card_accessor :followers

FOLLOW_CACHE_KEY = 'FOLLOW'
IGNORE_CACHE_KEY = 'IGNORE'

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
    (follower_ids - ignoramus_ids).map { |id| Card.find(id) }
  else
    Card::Set::All::Notify::FollowerStash.new(self).followers
  end
end


def follower_ids
  @follower_ids ||= Follow.cache[follow_key] || []
end

def followed_by? user
  follower_ids.include? user.id and not ingnored_by? user
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

def ignoramus_ids
  @ignoramus_ids ||= Follow.ignore_cache[follow_key] || []
end

def ignored_by? user
  ignoramus_ids.inclue? user.id
end

def add_ignoramus user
  if not ignored_by? user
    ignoramus_ids << user.id
  end
  save_ignoramuses ignoramus_ids
end

def drop_ignoramus user
  ignoramus_ids.delete(user.id)
  save_ignoramuses ignoramus_ids
end

def save_ignoramuses new_ignoramus
  hash = Follow.ignore_cache
  hash[follow_key] = new_new_ignoramus
  Follow.store_ignore_cache hash
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
    left_option = left
    while left_option
      sets << "#{left_option.name}+*self"
      left_option = left_option.left
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
      if link = render_follow_menu_item( :follow_menu_index => index ) and link.present?
        follow_links << link
      end
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
  
  view :follow_options do |args|
    if Auth.signed_in?
      args[:title] = "#{card.name}: follow options"
      #args[:optional_toggle] ||= main? ? :hide : :show
      frame_and_form( { :action=>:update, :id=>Auth.current.following_card.id, :success=>{:id=>card.name, :view=>:open} }, args, 'main-success'=>'REDIRECT' ) do
        [
          _render_follow_option_list( args ),
          _optional_render( :button_fieldset, args )
        ]
      end
    end
  end
  
  def default_follow_option_args args    
    args[:buttons] = %{
      #{ button_tag 'Submit', :class=>'submit-button', :disable_with=>'Submitting' }
      #{ button_tag 'Cancel', :class=>'cancel-button slotter', :href=>path, :type=>'button' }
    }
  end
  
  view :follow_option_list do |args|
    list = card.related_follow_option_cards.map do |option_card|
      subformat(option_card).render_checkbox(args.merge(:checked=>option_card.followed?, :label=>option_card.follow_label ))
    end.join("\n")
    %{
      <div class="card-editor editor">
      #{form.hidden_field( :content, :class=>'card-content')}
      <div class="pointer-checkbox-list">
        #{list}
      </div>
      </div>
    }
  end
  
  view :checkbox do |args|
    label = args[:label] || card.name
    checked = args[:checked]
    id = "pointer-checkbox-#{card.cardname.key}"
    %{ <div class="pointer-checkbox"> } +
      check_box_tag( "pointer_checkbox", card.cardname.url_key, checked, :id=>id, :class=>'pointer-checkbox-button') +
      %{ <label for="#{id}">#{label}</label>
      #{ %{<div class="checkbox-option-description">#{ args[:description] }</div>} if args[:description] }
       </div>}
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
    label        = if follow_option_card.respond_to? :follow_label
                    follow_option_card.follow_label
                      #follow_option_card.follow_label[0..0].downcase + follow_option_card.label[1..-1]
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
  Card.cache.write IGNORE_CACHE_KEY, nil
end

def self.cache
  Card.cache.read(FOLLOW_CACHE_KEY) || refresh_cached_sets
end

def self.store_cache hash
  Card.cache.write FOLLOW_CACHE_KEY, hash
  hash
end

def self.ignore_cache
  Card.cache.read(IGNORE_CACHE_KEY) || refresh_cached_sets
end

def self.store_ignore_cache hash
  Card.cache.write IGNORE_CACHE_KEY, hash
  hash
end

def self.refresh_cached_sets
  refresh_cache
  refresgh_ignore_cache
end

def self.refresh_cache
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

def self.refresh_ignore_cache
  ignore_cache = {}
  Card.search( :left=>{:type_id=>Card::UserID}, :right=>{:codename=> "ignore"} ).each do |ignoring_pointer|
    ignoring_pointer.item_cards.each do |ignored|
      key = ignored.follow_key
      if ignore_cache[key]
        ignore_cache[key] << ignoring_pointer.left_id
      else
        ignore_cache[key] = ::Set.new [ignoring_pointer.left_id]
      end
    end
  end
  Follow.store_ignore_cache ignore_cache
end
end
