
def stash_followers card_id, followers
  act_card.follower_stash ||= {}
  act_card.follower_stash[card_id] = card_followers
end

def act_card
  @supercard || self
end

event :record_followers, :after=>:approve, :on=>:delete do
  stash_followers id, card_followers
end

event :notify_followers, :after=>:extend, :when=>proc{ |c| !c.supercard }  do
  begin
    return unless @current_act
    @current_act.reload

    followers = @current_act.actions.map do |a|
       (@follower_stash and @follower_stash[a.card_id]) || (a.card and a.card.card_followers)
    end.compact.flatten.uniq
    followers.each do |w|
      if w.account
        w.account.send_change_notice @current_act #, self
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
      :unwatch_url  => wagn_url( "update/#{args[:watcher].to_name.url_key}+#{Card[:following].cardname.url_key}?drop_item=#{args[:watched].to_name.url_key}" ),
      :updater_url  => wagn_url( act.actor ),
      :watcher      => args[:watcher],
      :watched      => (args[:watched] == card.cardname ? args[:watched] : "#{args[:watched]} cards"),
      :action_type  => action_on_card ? "#{action_on_card.action_type}d" : "updated",
      :salutation   => args[:watcher] ? "Dear #{args[:watcher]}" : "Dear #{Card.setting :title} user",
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
  
  def wrap_subedit_item text
    "\n#{text}\n"
  end
  
  def wrap_subedits subedits
    "\nThis update included the following changes:#{wrap_list subedits}"
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
  You received this email because you\'re following "\#{watched}". 
  %br
  %a{:href=>unwatch_url}
    Unfollow
  to stop receiving these emails.
}
  end
end


format :text do    
  view :change_notice, :perms=>:none, :denial=>:blank do |args|
    render_template_with_change_notice_locals :erb, args, %{
<%= salutation %>

"<%= card_name %>"
was just <%= action_type %> by <%= updater_name %>
<%= selfedits if selfedits.present? -%>
<%= wrap_subedits subedits if subedits.present? -%>

See the card: <%= card_url %>

You received this email because youre following "<%= watched %>".
Visit <%= unwatch_url %> to stop receiving these emails.
      }.strip
  end
end

