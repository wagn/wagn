
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
  def edit_info args
    action = args[:action] || (args[:action_id] and Card::Action.find(args[:action_id])) || card.last_action
    action.edit_info
  end
  
  def change_notice_args args
    act = args[:act_id] ? Card::Act.find(args[:act_id]) : card.acts.last
  
    {
      :act         => act,
      :card_url    => wagn_url(card),
      :change_url  => wagn_url("#{card.cardname.url_key}?view=history"), 
      :unwatch_url => wagn_url( "update/#{args[:watcher].to_name.url_key}+#{Card[:following].cardname.url_key}?drop_item=#{args[:watched].to_name.url_key}" ),
      :updater_url => wagn_url( act.actor ),
      :watcher     => args[:watcher],
      :watched     => (args[:watched] == card.cardname ? args[:watched] : "#{args[:watched]} cards"),
      :edit        => (action = act.action_on(card.id) and action.edit_info)
    }
  end  
end

format :email_html do
  def wrap_subedits subedits
    %{
      This update included the following changes
      <ul>
        #{subedits}
      </ul>
    }
  end
  
  
  view :change_notice, :perms=>:none, :denial=>:blank do |args|
    h = change_notice_args(args)
    salutation  = h[:watcher] ? "Dear #{h[:watcher]}" : "Dear #{Card.setting :title} user"
    selfedits   = render_list_of_changes(args)
    action_type = h[:edit] ? h[:edit][:action_type] : "updated"
    subedits    = h[:act].relevant_actions_for(card).map do |action| 
        action.card_id == card.id ? '' : action.card.format(:format=>:email).render_subedit_notice(:action=>action)
    end.join
    return '' unless selfedits.present? or subedits.present? or action_type == "deleted"
      %{
        #{salutation}
        <p>
          <a href="#{h[:card_url]}">"#{card.name}"</a> 
          was just <a href="#{h[:change_url]}">#{action_type}</a>
          by <a href="#{h[:updater_url]}">#{h[:act].actor.name}</a>
        </p>
      
        #{ selfedits }
      
        #{ wrap_subedits subedits if subedits.present? }
      
        <p>See the card: <a href="#{h[:card_url]}">"#{h[:card_url]}"</a></p>

        <p>
          You received this email because you're following "#{h[:watched]}". <br/>
          <a href="#{h[:unwatch_url]}">Unfollow</a> to stop receiving these emails.
        </p>
      }
  end
  
  view :list_of_changes, :denial=>:blank do |args|
    edit = edit_info(args)
    case edit[:action_type]
    when 'created'
      %{
        <ul>
        #{"<li>cardtype: #{edit[:new_cardtype]}</li>" if edit[:new_cardtype] }
        #{"<li>content: #{edit[:new_content]}</li>"   if edit[:new_content] }
        </ul>
      }
    when 'updated'
      %{
        <ul>
        #{"<li>new name: #{edit[:new_name]}</li>"         if edit[:new_name] }
        #{"<li>new cardtype: #{edit[:new_cardtype]}</li>" if edit[:new_cardtype] }
        #{"<li>new content: #{edit[:new_content]}</li>"   if edit[:new_content] }
        </ul>
      }
    when 'deleted'
      ''
    end
  end
  
  view :subedit_notice, :perms=>:read, :denial=>:blank do |args|
    edit = edit_info(args)
    %{
      <li>#{edit[:new_name] && edit[:old_name] ? edit[:old_name] : card.name} #{edit[:action_type]}
      #{ render_list_of_changes(args) }
      </li>
    }
  end
end


format :text do
  def wrap_subedits subedits
    %{
This update included the following changes:
#{subedits}}
  end
  
  
  view :change_notice, :perms=>:none, :denial=>:blank do |args|
    h = change_notice_args(args)
    salutation  = h[:watcher] ? "Dear #{h[:watcher]}" : "Dear #{Card.setting :title} user"
    selfedits   = render_list_of_changes(args)
    subedits    = h[:act].actions.map do |action| 
        action.card_id == card.id ? '' : action.card.format(:format=>:text).render_subedit_notice(:action=>action)
    end.join
    
    return '' unless selfedits.present? or subedits.present?
      %{
#{salutation}

"#{card.name}"
was just #{h[:edit] ? h[:edit][:action_type] : "updated"} by #{h[:act].actor.name}
#{ selfedits }
#{ wrap_subedits subedits if subedits.present? }

See the card: #{h[:card_url]}

You received this email because you're following "#{h[:watched]}". 
Visit #{h[:unwatch_url]} to stop receiving these emails.
      }
  end
  
  view :list_of_changes, :denial=>:blank do |args|
    edit = edit_info(args)
    case edit[:action_type]
    when 'created'
      [
        ("   cardtype: #{edit[:new_cardtype]}" if edit[:new_cardtype]),
        ("   content: #{edit[:new_content]}"   if edit[:new_content]) 
      ].compact.join "\n"
    when 'updated'
      [
        ("   new name: #{edit[:new_name]}"         if edit[:new_name]),
        ("   new cardtype: #{edit[:new_cardtype]}" if edit[:new_cardtype]),
        ("   new content: #{edit[:new_content]}"   if edit[:new_content])
      ].compact.join "\n"
    when 'deleted'
      ''
    end
  end
  
  view :subedit_notice, :denial=>:blank do |args|
    edit = edit_info(args)
    %{
"#{edit[:new_name] && edit[:old_name] ? edit[:old_name] : card.name}" #{edit[:action_type]}
      #{ render_list_of_changes(args) }
    }
  end
end
