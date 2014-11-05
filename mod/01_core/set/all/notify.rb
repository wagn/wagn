
class FollowerStash  
  def initialize card=nil
    @followed_affected_cards = Hash.new { |h,v| h[v]=[] } 
    @visited = ::Set.new
    add_affected_card(card) if card
  end
    
  def add_affected_card card
    Auth.as_bot do
      if !@visited.include? card.name
        @visited.add card.name
        # add card followers
        Card.search( :right_plus=>[{:codename=> "following"}, 
                             {:link_to=>card.name}     ]
                   ).each do |follower|
                     notify follower, :of => card.name
                   end
        # add cardtype followers
        Card.search( :right_plus=>[{:codename=> "following"}, 
                             {:link_to=>card.type_name} ]
                   ).each do |follower|
                    notify follower, :of => card.type_name
                  end
        Card.search(:include=>card.name).each do |includer| 
          add_affected_card includer unless @visited.include? includer.name
        end
        if card.left and !@visited.include?(card.left.name) and
           includee_set = Card.search(:included_by=>card.left.name).map(&:name) and
           !@visited.intersection(includee_set).empty?
              add_affected_card card.left
        end
      end
    end
  end
  
  def followers
    @followed_affected_cards.keys
  end
  
  def each_follower_followed_pair  # "follower" is a card object, "followed" a card name
    @followed_affected_cards.each do |user, card_names|
      yield(user,card_names.first)
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

event :notify_followers, :after=>:extend, :when=>proc{ |c| !c.supercard and c.current_act}  do
  begin
    @current_act.reload
    @follower_stash ||= FollowerStash.new

    @current_act.actions.each do |a|
      @follower_stash.add_affected_card a.card
    end
    @follower_stash.each_follower_followed_pair do |follower, followed|
      if follower.account and follower != @current_act.actor
        follower.account.send_change_notice @current_act, followed
      end
    end
  rescue =>e  #this error handling should apply to all extend callback exceptions
    Airbrake.notify e if Airbrake.configuration.api_key
    Rails.logger.info "\nController exception: #{e.message}"
    Rails.logger.debug "BT: #{e.backtrace*"\n"}"
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
  
  
  view :subedits do |args|
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
    @last_act ||= args[:act_id] ? Card::Act.find(args[:act_id]) : card.acts.last
    @last_act
  end
  
  def get_action args
    args[:action] || (args[:action_id] and Card::Action.find(args[:action_id])) || card.last_action
  end
  
  
  def wrap_subedits subedits
    "\nThis update included the following changes:#{wrap_list subedits}"
  end
   
end

format :email_text do 
  view :last_action do |args|
    act = get_act(args)
    action_on_card =  act.action_on(act.card_id) || act.actions.first
    "#{action_on_card.action_type}d"
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

format :email_html do  
  view :last_action do |args|
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




