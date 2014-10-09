
class FollowerStash  
  def initialize card=nil
    @followed_affected_cards = Hash.new { |h,v| h[v]=[] } 
    @visited = ::Set.new
    add_affected_card(card) if card
  end
    
  def add_affected_card card
    if !@visited.include? card.name
      @visited.add card.name
      # add card followers
      Card.search( :plus=>[{:codename=> "following"}, 
                           {:link_to=>card.name}     ]
                 ).each do |follower|
                   notify follower, :of => card.name
                 end
      # add cardtype followers
      Card.search( :plus=>[{:codename=> "following"}, 
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

event :notify_followers, :after=>:extend, :when=>proc{ |c| !c.supercard }  do
  begin
    return unless @current_act
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
  def get_action args
    args[:action] || (args[:action_id] and Card::Action.find(args[:action_id])) || card.last_action
  end
  
  def change_notice_locals args
    act = args[:act_id] ? Card::Act.find(args[:act_id]) : card.acts.last
    action_on_card = act.action_on(card.id)
    
    selfedits   = render_list_of_changes(args)
    subedits    = act.relevant_actions_for(card).map do |action| 
        action.card_id == card.id ? '' : action.card.format(:format=>@format).render_subedit_notice(:action=>action)
    end.join
    
    {
      :card_name    => card.name,
      :updater_name => act.actor.name,
      :card_url     => wagn_url(card),
      :change_url   => wagn_url("#{card.cardname.url_key}?view=history"), 
      :unfollow_url => wagn_url( "update/#{args[:follower].to_name.url_key}+#{Card[:following].cardname.url_key}?drop_item=#{args[:followed].to_name.url_key}" ),
      :updater_url  => wagn_url( act.actor ),
      :follower     => args[:follower],
      :followed     => args[:followed],
      :action_type  => action_on_card ? "#{action_on_card.action_type}d" : "updated",
      :salutation   => args[:follower] ? "Dear #{args[:follower]}" : "Dear #{Card.setting :title} user",
      :selfedits    => selfedits,
      :subedits     => subedits
    }
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
  
  def wrap_list list
    "\n#{list}"
  end
  
  def wrap_list_item item
    "   #{item}\n"
  end
  
  def wrap_subedits subedits
    "\nThis update included the following changes:#{wrap_list subedits}"
  end
  
  def wrap_subedit_item text
    "\n#{text}\n"
  end
  
  view :subedit_notice, :denial=>:blank do |args|
    action = get_action(args)
    name_before_action = (action.new_values[:name] && action.old_values[:name]) || card.name
    
    wrap_subedit_item %{#{name_before_action} #{action.action_type}d
#{ render_list_of_changes(args) }}
  end
  
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
  
  def render_template_with_change_notice_locals type, args, template
    locals = change_notice_locals(args)
    if locals[:selfedits].present? or locals[:subedits].present? or locals[:action_type] == "deleted"  
      if type == :haml
        render_haml locals, template, binding
      elsif type == :erb
        render_erb locals, template
      else
        template
      end
    else
      ''
    end
  end
end

format :email_html do
  # def edit_info_for field, action
  #   if field == :content and action.action_type == :update
  #      wrap_list_item "content changes: #{render_content_changes :diff_type=>:summary, :action=>action}"
  #   else
  #     super
  #   end
  # end
  
  def wrap_list list
    "<ul>#{list}</ul>\n"
  end

  def wrap_list_item item
    "<li>#{item}</li>\n"
  end
  
  def wrap_subedit_item text
    "<li>#{text}</li>\n"
  end
  
  view :change_notice, :perms=>:none, :denial=>:blank do |args|
    render_template_with_change_notice_locals :haml, args, %{
= salutation
%p
  %a{:href=>card_url}
    = card_name
  was just 
  %a{:href=>change_url}
    = action_type
  by 
  %a{:href=>updater_url}
    = updater_name
%p
  = selfedits
  - if subedits.present?
    = wrap_subedits subedits 
%p
  See the card: 
  %a{:href=>card_url}
    "\#{card_url}"
%p
  You received this email because you\'re following "\#{followed}". 
  %br
  %a{:href=>unfollow_url}
    Unfollow
  to stop receiving these emails.
}
  end
end


format :text do    
  view :change_notice, :perms=>:none, :denial=>:blank do |args|
    render_template_with_change_notice_locals :erb, args, %{
<%= @salutation %>

"<%= @card_name %>"
was just <%= @action_type %> by <%= @updater_name %>
<%= @selfedits if @selfedits.present? -%>
<%= wrap_subedits @subedits if @subedits.present? -%>

See the card: <%= @card_url %>

You received this email because you're following "<%= @followed %>".
Visit <%= @unfollow_url %> to stop receiving these emails.
      }.strip
  end
end

