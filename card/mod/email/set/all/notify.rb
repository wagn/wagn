
class FollowerStash
  def initialize card=nil
    @followed_affected_cards = Hash.new { |h, v| h[v] = [] }
    @visited = ::Set.new
    add_affected_card(card) if card
  end

  def add_affected_card card
    return if @visited.include? card.key
    Auth.as_bot do
      @visited.add card.key
      notify_direct_followers card
      return if !(left_card = card.left) || @visited.include?(left_card.key) ||
                !(follow_field_rule = left_card.rule_card(:follow_fields))
      follow_field_rule.item_names(context: left_card.cardname).each do |item|
        if @visited.include? item.to_name.key
          add_affected_card left_card
          break
        elsif item.to_name.key == Card[:includes].key
          includee_set = Card.search(
            { included_by: left_card.name },
            "follow cards included by #{left_card.name}"
          ).map(&:key)
          unless @visited.intersection(includee_set).empty?
            add_affected_card left_card
            break
          end
        end
      end
    end
  end

  def followers
    @followed_affected_cards.keys
  end

  def each_follower_with_reason
    # "follower"(=user) is a card object, "followed"(=reasons) a card name
    @followed_affected_cards.each do |user, reasons|
      yield(user, reasons.first)
    end
  end

  private

  def notify_direct_followers card
    card.all_direct_follower_ids_with_reason do |user_id, reason|
      notify Card.fetch(user_id), of: reason
    end
  end

  def notify follower, because
    @followed_affected_cards[follower] << because[:of]
  end
end

def act_card
  @supercard || self
end

def followable?
  true
end

def silent_change
  @silent_change || (@supercard && @supercard.silent_change)
end

def silent_change?
  silent_change.nil? ? !Card::Env[:controller] : silent_change
end

def notable_change?
  !silent_change? && current_act_card? &&
    Card::Auth.current_id != WagnBotID && followable?
end

def current_act_card?
  current_act && current_act.card_id == id
end

event :notify_followers_after_save, :integrate_with_delay,
      on: :save, when: proc { |ca| ca.notable_change? } do
  notify_followers
end

# in the delete case we have to calculate the follower_stash beforehand
# but we can't pass the follower_stash through the ActiveJob queue.
# We have to deal with the notifications in the integrate phase instead of the
# integrate_with_delay phase
event :stash_followers, :store, on: :delete do
  act_card.follower_stash ||= FollowerStash.new
  act_card.follower_stash.add_affected_card self
end
event :notify_followers_after_delete, :integrate,
      on: :delete, when: proc { |ca| ca.notable_change? } do
  notify_followers
end

def notify_followers
  @current_act.reload
  @follower_stash ||= FollowerStash.new
  @current_act.actions.each do |a|
    next if !a.card || a.card.silent_change?
    @follower_stash.add_affected_card a.card
  end
  @follower_stash.each_follower_with_reason do |follower, reason|
    if follower.account && follower != @current_act.actor
      follower.account.send_change_notice @current_act, reason[:set_card].name,
                                          reason[:option]
    end
  end
# this error handling should apply to all extend callback exceptions
rescue => e
  Rails.logger.info "\nController exception: #{e.message}"
  Card::Error.current = e
  notable_exception_raised
end

format do
  view :list_of_changes, denial: :blank do |args|
    action = get_action(args)

    relevant_fields =
      case action.action_type
      when :create then [:cardtype, :content]
      when :update then [:name, :cardtype, :content]
      when :delete then [:content]
      end

    relevant_fields.map do |type|
      edit_info_for(type, action)
    end.compact.join
  end

  view :subedits, perms: :none do |args|
    subedits =
      get_act(args).relevant_actions_for(card).map do |action|
        if action.card_id != card.id
          action.card.format(format: @format)
                .render_subedit_notice(action: action)
        end
      end.compact.join

    if subedits.present?
      wrap_subedits subedits
    else
      ""
    end
  end

  view :subedit_notice, denial: :blank do |args|
    action = get_action(args)
    name_before_action =
      (action.value(:name) && action.previous_value(:name)) || card.name

    wrap_subedit_item %(#{name_before_action} #{action.action_type}d
#{render_list_of_changes(args)})
  end

  view :followed, perms: :none, closed: true do |args|
    if args[:followed_set] &&
       (set_card = Card.fetch(args[:followed_set])) &&
       args[:follow_option] &&
       (option_card = Card.fetch(args[:follow_option]))
      option_card.description set_card
    else
      "followed card"
    end
  end

  view :follower, perms: :none, closed: true do |args|
    args[:follower] || "follower"
  end

  view :unfollow_url, perms: :none, closed: true do |args|
    if args[:followed_set] && (set_card = Card.fetch(args[:followed_set])) &&
       args[:follow_option] && args[:follower]
      rule_name = set_card.follow_rule_name args[:follower]
      target_name = "#{args[:follower]}+#{Card[:follow].name}"
      update_path = page_path target_name,
                              action: :update,
                              card: { subcards: {
                                rule_name => Card[:never].name
                              } }
      card_url update_path # absolutize path
    end
  end

  def edit_info_for field, action
    return nil unless action.value field

    item_title =
      case action.action_type
      when :update then "new "
      when :delete then "deleted "
      else ""
      end
    item_title += "#{field}: "

    item_value =
      if action.action_type == :delete
        action.previous_value field
      else
        action.value field
      end

    wrap_list_item "#{item_title}#{item_value}"
  end

  def get_act args
    @notification_act ||= args[:act] ||
                          (args[:act_id] && Act.find(args[:act_id])) ||
                          card.acts.last
  end

  def get_action args
    args[:action] || (args[:action_id] && Action.fetch(args[:action_id])) ||
      card.last_action
  end

  def wrap_subedits subedits
    "\nThis update included the following changes:#{wrap_list subedits}"
  end

  def wrap_list list
    "\n#{list}\n"
  end

  def wrap_list_item item
    "   #{item}\n"
  end

  def wrap_subedit_item text
    "\n#{text}\n"
  end
end

format :email_text do
  view :last_action, perms: :none do |args|
    act = get_act(args)
    "#{act.main_action.action_type}d"
  end
end

format :email_html do
  view :last_action, perms: :none do |args|
    act = get_act(args)
    "#{act.main_action.action_type}d"
  end

  def wrap_list list
    "<ul>#{list}</ul>\n"
  end

  def wrap_list_item item
    "<li>#{item}</li>\n"
  end

  def wrap_subedit_item text
    "<li>#{text}</li>\n"
  end
end
