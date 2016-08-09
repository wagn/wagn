card_accessor :followers

FOLLOWER_IDS_CACHE_KEY = "FOLLOWER_IDS".freeze

# FIXME: this should be in type/set
event :cache_expired_for_new_set, :store,
      on: :create,
      when: proc { |c| c.type_id == Card::SetID } do
  Card.follow_caches_expired
end

event :cache_expired_for_type_change, :store,
      on: :update, changed: [:type_id, :name] do
  # FIXME: expire (also?) after save
  Card.follow_caches_expired
end

event :cache_expired_for_new_preference, :integrate,
      when: proc { |c| c.follow_rule_card? }  do
  Card.follow_caches_expired
end

format do
  def follow_link_hash args
    toggle = args[:toggle] || (card.followed? ? :off : :on)
    hash = { class: "follow-toggle-#{toggle}" }
    these_emails = "emails about changes to #{card.follow_label}"
    case toggle
    when :off
      hash[:content] = "*never"
      hash[:title]   = "stop sending #{these_emails}"
      hash[:verb]    = "unfollow"
    when :on
      hash[:content] = "*always"
      hash[:title]   = "send #{these_emails}"
      hash[:verb]    = "follow"
    end
    set_card = card.default_follow_set_card
    hash[:path] = path(
      name: set_card.follow_rule_name(Auth.current.name),
      action: :update,
      success: { layout: :modal, view: :follow_status },
      card: { content: "[[#{hash[:content]}]]" }
    )
    hash
  end
end

format :json do
  view :follow_status do |args|
    follow_link_hash args
  end
end

format :html do
  view :follow_link, tags: :unknown_ok, perms: :none do |args|
    hash = follow_link_hash args
    text = args[:icon] ? glyphicon("flag") : ""
    span_attrs = "follow-verb menu-item-label"
    text += %(<span class="#{span_attrs}">#{hash[:verb]}</span>).html_safe
    # follow_rule_card = Card.fetch(
    #   card.default_follow_set_card.follow_rule_name(Auth.current.name),
    #   new: {}
    # )
    opts = (args[:html_args] || {}).clone
    opts.merge!(
      title:           hash[:title],
      "data-path"      => hash[:path],
      "data-toggle"    => "modal",
      "data-target"    => "#modal-#{card.cardname.safe_key}"
    )
    opts[:class] = "follow-link #{opts[:class]}"
    link_to text, hash[:path], opts
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
  is_preference? && rule_setting_name == "*follow"
end

def follow_option?
  codename && FollowOption.codenames.include?(codename.to_sym)
end

# used for the follow menu overwritten in type/set.rb and type/cardtype.rb
# for sets and cardtypes it doesn't check whether the users is following the
# card itself instead it checks whether he is following the complete set
def followed_by? user_id
  with_follower_candidate_ids do
    return true if follow_rule_applies? user_id
    return true if (left_card = left) &&
                   left_card.followed_field?(self) &&
                   left_card.followed_by?(user_id)
    false
  end
end

def followed?
  followed_by? Auth.current_id
end

def follow_rule_applies? follower_id
  follow_rule = rule :follow, user_id: follower_id
  if follow_rule.present?
    follow_rule.split("\n").each do |value|
      value_code = value.to_name.code
      accounted_ids = (
        @follower_candidate_ids[value_code] ||=
          if (block = FollowOption.follower_candidate_ids[value_code])
            block.call self
          else
            []
          end
      )

      applicable =
        if (test = FollowOption.test[value_code])
          test.call follower_id, accounted_ids
        else
          accounted_ids.include? follower_id
        end

      return value.gsub(/[\[\]]/, "") if applicable
    end
  end
  false
end

def with_follower_candidate_ids
  @follower_candidate_ids = {}
  yield
  @follower_candidate_ids = nil
end

# the set card to be followed if you want to follow changes of card
def default_follow_set_card
  Card.fetch("#{name}+*self")
end

# returns true if according to the follow_field_rule followers of self also
# follow changes of field_card
def followed_field? field_card
  (follow_field_rule = rule_card(:follow_fields)) ||
    follow_field_rule.item_names.find do |item|
      item.to_name.key == field_card.key || (item.to_name.key == Card[:includes].key && included_card_ids.include?(field_card.id))
    end
end

def follower_ids
  @follower_ids = read_follower_ids_cache || begin
    result = direct_follower_ids
    left_card = left
    while left_card
      result += left_card.direct_follower_ids if left_card.followed_field? self
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

# all ids of users that follow this card because of a follow rule that applies
# to this card doesn't include users that follow this card because they are
# following parent cards or other cards that include this card
def direct_follower_ids _args={}
  result = ::Set.new
  with_follower_candidate_ids do
    set_names.each do |set_name|
      set_card = Card.fetch(set_name)
      set_card.all_user_ids_with_rule_for(:follow).each do |user_id|
        if !result.include?(user_id) && follow_rule_applies?(user_id)
          result << user_id
        end
      end
    end
  end
  result
end

def all_direct_follower_ids_with_reason
  with_follower_candidate_ids do
    visited = ::Set.new
    set_names.each do |set_name|
      set_card = Card.fetch(set_name)
      set_card.all_user_ids_with_rule_for(:follow).each do |user_id|
        if !visited.include?(user_id) &&
           (follow_option = follow_rule_applies?(user_id))
          visited << user_id
          yield(user_id, set_card: set_card, option: follow_option)
        end
      end
    end
  end
end

# ~~~~~ cache methods

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
    Card.clear_preference_cache
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
