card_accessor :followers

REVERSE_FOLLOWING_CACHE_KEY = 'FOLLOWING'
REVERSE_IGNORING_CACHE_KEY = 'IGNORING'
FOLLOWER_CACHE_KEY = 'FOLLOWER'



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
    Follow.read_follower_cache(key) || begin
      Follow.write_follower_cache key, find_all_followers 
    end
  end
end

# find all followers
def find_all_followers
  res = ::Set.new
  all_follow_option_cards.each do |option_card|
    (option_card.follower_ids - option_card.ignoramus_ids).each do |follower_id|
      res << Card.fetch(follower_id)
    end
  end

  if left and follow_field_rule = left.rule_card(:follow_fields)
    follow_field_rule.item_names(:context=>left.cardname).each do |item|
      if item.to_name.key == key or 
         (item == Card[:includes].name and left.included_card_ids.include? id)
        res += left.followers
        break
      end
    end
  end
  res
end


def followed?; followed_by? Auth.current end

def followed_by? user
  followers.include? user
end

def ignored_by? user
  ignore_set_card.ignoramus_ids.include? user.id
end

def ignored?
  ignored_by? Auth.current
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


def ignore_set_card
  if type_code == :set and right.codename == "self"
    self
  else
    fetch(:trait=>:self)
  end  
end

def ignore_set
  ignore_set_card.name
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



event :cache_expired_because_of_card_change, :before=>:extend, :on=>:update
  #Follow.cache_expired
  ''
end

event :cache_expired_because_of_new_set, :before=>:extend, :on=>:create, :when=> proc { |c| c.type_id == Card::SetID } do
  Follow.set_cache_expired
end

event :cache_expired_because_of_type_change, :before=>:extend, :changed=>:type_id do
  Follow.set_cache_expired
end

event :cache_expired_because_of_name_change, :before=>:extend, :changed=>:name do
  Follow.set_cache_expired
end

event :follow_change, :before=>:extend, :when=> proc {|c| Env.params[:follow] || Env.params[:unfollow]} do
  binding.pry
  if followed? 
    if Env.params[:unfollow]
      if Auth.current.following_card.include_item? follow_set_card
        following_card = Auth.current.following_card
        following_card.drop_item follow_set
        following_card.save!
      else
        ignoring_card = Auth.current.ignoring_card
        ignoring_card.add_item ignore_set
        ignoring_card.save
      end
    end
  else
    if Env.params[:follow]
      if ignored? 
        ignoring_card = Auth.current.ignoring_card
        ignoring_card.drop_item ignore_set
        ignoring_card.save
      else
        following_card = Auth.current.following_card
        following_card.add_item follow_set
        following_card.save!
      end
    end
  end
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

  def follow_link index_or_card, link_label=nil, success_view=:follow_menu_item
    follow_option_card = if Integer===index_or_card
        card.related_follow_option_cards[index_or_card]
      else
        index_or_card
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
    path_options = {:card=>card, :action=>:update, :follow_menu_index=>index,
                    :success=>{:id=>card.name, :view=>success_view} }
    html_options = {:class=>"watch-toggle watch-toggle-#{toggle} slotter", :remote=>true, :method=>'post'}

    link_label ||= " #{label}"
    case toggle
    when :off
      text                         = "following#{link_label}"
      #path_options[:drop_item]     = follow_option_card.cardname.url_key
      path_options[:unfollow]      = true
      html_options[:title]         = "stop sending emails about changes to #{label}"
      html_options[:hover_content] = "unfollow#{link_label}"
    when :on
      text                         = "follow#{link_label}"
      #path_options[:add_item]      = follow_option_card.cardname.url_key
      path_options[:follow]        = true
      html_options[:title]         = "send emails about changes to #{label}"
    end
    link_to text, path(path_options), html_options
  end
end


module ClassMethods 
  def reverse_following_cache
    Card.cache.read(REVERSE_FOLLOWING_CACHE_KEY) || refresh_cached_sets
  end

  def reverse_ignoring_cache
    Card.cache.read(REVERSE_IGNORING_CACHE_KEY) || refresh_cached_sets
  end

  def follower_cache
    Card.cache.read(FOLLOWER_CACHE_KEY) || {}
  end


  def clear_reverse_following_cache
    Card.cache.write REVERSE_FOLLOWING_CACHE_KEY, nil
  end

  def clear_reverse_ignoring_cache
    Card.cache.write REVERSE_IGNORING_CACHE_KEY, nil
  end

  def clear_follower_cache
    Card.cache.write FOLLOWER_CACHE_KEY
  end

  def clear_follow_caches
    clear_reverse_ignoring_cache
    clear_reverse_following_cache
    clear_follower_cache
  end

  def read_reverse_following_cache card
    reverse_following_cach
    Card.cache.read(REVERSE_FOLLOWING_CACHE_KEY)[card.key]
  end
  
  def read_reverse_ignoring_cache card
    Card.cache.read(REVERSE_IGNORING_CACHE_KEY)[card.key]
  end
  
  def read_follower_cache card
    Card.cache.read(FOLLOW_CACHE_KEY)[card.key]
  end


  def refresh_cached_sets
    refresh_cache
    refresh_ignore_cache
  end

  def refresh_cache
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

  def refresh_ignore_cache
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
