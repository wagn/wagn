
class FollowerStash  
  def initialize card=nil
    @followed_affected_cards = Hash.new { |h,v| h[v]=[] } 
    @visited = ::Set.new
    add_affected_card(card) if card
  end
    
  def add_affected_card card
    Auth.as_bot do
      if !@visited.include? card.key
        @visited.add card.key
        card.all_direct_follower_ids_with_reason do |user_id, reason|
          notify Card.fetch(user_id), :of=>reason
        end
        if card.left and !@visited.include?(card.left.name) and follow_field_rule = card.left.rule_card(:follow_fields)
          
          follow_field_rule.item_names(:context=>card.left.cardname).each do |item|  
            if @visited.include? item.to_name.key
              add_affected_card card.left
              break
            elsif item.to_name.key == Card[:includes].key
              includee_set = Card.search(:included_by=>card.left.name).map(&:key)
              if !@visited.intersection(includee_set).empty?
                add_affected_card card.left
                break
              end
            end
          end
          
        end 
    
      end

    end
  end
  
  def followers
    @followed_affected_cards.keys
  end
  
  def each_follower_with_reason  # "follower" is a card object, "followed" a card name
    @followed_affected_cards.each do |user, reasons|
      yield(user,reasons.first)
    end
  end
  
  private
  
  def notify follower, because
    @followed_affected_cards[follower] << because[:of]
  end
  
end

def act_card
  @supercard || self
end

event :stash_followers, :after=>:approve, :on=>:delete do
  act_card.follower_stash ||=  FollowerStash.new
  act_card.follower_stash.add_affected_card self
end

event :notify_followers, :after=>:extend, :when=>proc{ |c|
    !c.supercard and c.current_act and Card::Auth.current_id != WagnBotID 
  }  do
    
  begin
    @current_act.reload
    @follower_stash ||= FollowerStash.new
    @current_act.actions.each do |a|
      @follower_stash.add_affected_card a.card if a.card
    end
    @follower_stash.each_follower_with_reason do |follower, reason|
      if follower.account and follower != @current_act.actor
        follower.account.send_change_notice @current_act, reason[:set_card].name, reason[:option]
      end
    end
  rescue =>e  #this error handling should apply to all extend callback exceptions
    Rails.logger.info "\nController exception: #{e.message}"
    Card::Error.current = e
    notable_exception_raised
  end
end
  
format do  
  view :list_of_changes, :denial=>:blank do |args|
    action = get_action(args)
    
    relevant_fields = case action.action_type
      when :create then [:cardtype, :content]
      when :update then [:name, :cardtype, :content]
      when :delete then [:content]
      end
    
    relevant_fields.map do |type| 
      edit_info_for(type, action)
    end.compact.join
  end
  
  
  view :subedits, :perms=>:none do |args|
    subedits = get_act(args).relevant_actions_for(card).map do |action| 
        if action.card_id != card.id 
          action.card.format(:format=>@format).render_subedit_notice(:action=>action)
        end
      end.compact.join
      
    if subedits.present?
      wrap_subedits subedits
    else
      ''
    end
  end
    
  view :subedit_notice, :denial=>:blank do |args|
    action = get_action(args)
    name_before_action = (action.new_values[:name] && action.old_values[:name]) || card.name
    
    wrap_subedit_item %{#{name_before_action} #{action.action_type}d
#{ render_list_of_changes(args) }}
  end
  
  view :followed, :perms=>:none, :closed=>true do |args|
    if args[:followed_set] && (set_card = Card.fetch(args[:followed_set])) && 
         args[:follow_option] && (option_card = Card.fetch(args[:follow_option]))
       option_card.description set_card
    else
      'followed card'
    end
  end

  view :follower, :perms=>:none, :closed=>true do |args|
    args[:follower] || 'follower'
  end
  
  view :unfollow_url, :perms=>:none, :closed=>true do |args|
    if args[:followed_set] && (set_card = Card.fetch(args[:followed_set])) && args[:follow_option] && args[:follower]
     rule_name = set_card.follow_rule_name args[:follower]    
     target_name = "#{args[:follower]}+#{Card[:follow].name}"
     update_path = page_path target_name, :action=>:update, :card=>{:subcards=>{rule_name=>Card[:never].name}}
     card_url update_path # absolutize path
    end
  end
  
  def edit_info_for field, action
    return nil unless action.new_values[field]
    
    item_title = case action.action_type
    when :update then 'new '
    when :delete then 'deleted '
    else ''
    end
    item_title +=  "#{field}: "

    item_value = if action.action_type == :delete
      action.old_values[field]
    else
      action.new_values[field]
    end
    
     wrap_list_item "#{item_title}#{item_value}"
  end
  
  def get_act args
    @notification_act ||= args[:act] || (args[:act_id] and Act.find(args[:act_id])) || card.acts.last
  end
  
  def get_action args
    args[:action] || (args[:action_id] and Action.fetch(args[:action_id])) || card.last_action
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
  view :last_action, :perms=>:none do |args|
    act = get_act(args)
    action_on_card =  act.action_on(act.card_id) || act.actions.first
    "#{action_on_card.action_type}d"
  end
end

format :email_html do  
  view :last_action, :perms=>:none do |args|
    act = get_act(args)
    action_on_card =  act.action_on(act.card_id) || act.actions.first
    "#{action_on_card.action_type}d"
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




