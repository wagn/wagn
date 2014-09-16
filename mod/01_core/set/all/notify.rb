require 'pry'

format do
  def wrap_subedits subedits
    %{
      This update included the following changes
      <ul>
        #{subedits}
      </ul>
    }
  end
  
  def edit_info args
    action = args[:action] || (args[:action_id] and Card::Action.find(args[:action_id])) || card.last_action
    action.edit_info
  end
  
  def change_notice_args args
    act = args[:act_id] ? Card::Act.find(args[:act_id]) : card.acts.last
    {
      :act         => act,
      :card_url    => wagn_url(card),
      :change_url  => wagn_url( "card/changes/#{card.cardname.url_key}" ),
      :unwatch_url => wagn_url( "card/watch/#{args[:watched].to_name.url_key}?toggle=off" ),
      :updater_url => wagn_url( act.actor ),
      :watcher     => args[:watcher],
      :watched     => (args[:watched] == card.cardname ? args[:watched] : "#{args[:watched]} cards"),
      :edit        => act.action_on(card.id).edit_info
    }
  end  
end

format :html do
  view :change_notice, :skip_permissions=>true, :denial=>:blank do |args|
    h = change_notice_args(args)
    salutation  = h[:watcher] ? "Dear #{h[:watcher]}" : "Dear #{Card.setting :title} user"
    selfedits   = render_list_of_changes(args)
    
    subedits    = h[:act].actions.map do |action| 
        action.card_id == card.id ? '' : action.card.format(:format=>:html).render_subedit_notice(:action=>action)
    end.join
    return '' unless selfedits.present? or subedits.present?
      %{
        #{salutation}
        <p>
          <a href="#{h[:card_url]}">#{card.name}</a> 
          was just <a href="#{h[:change_url]}">#{h[:edit][:action_type]}</a>
          by <a href="#{h[:updater_url]}">#{h[:act].actor.name}</a>
        </p>
      
        #{ selfedits }
      
        #{ wrap_subedits subedits if subedits.present? }
      
        <p>See the card: "#{h[:card_url]}"</p>

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
        #{'<li>the name was changed</li>'                 if edit[:new_name] }
        #{"<li>new cardtype: #{edit[:new_cardtype]}</li>" if edit[:new_cardtype] }
        #{"<li>new content: #{edit[:new_content]}</li>"   if edit[:new_content] }
        </ul>
      }
    when 'deleted'
      ''
    end
  end
  
  view :subedit_notice, :denial=>:blank do |args|
    edit = edit_info(args)
    %{
      <li>#{card.name} #{edit[:action_type]}
      #{ render_list_of_changes(args) }
      </li>
    }
  end
end


format :text do
  view :change_notice, :skip_permissions=>true, :denial=>:blank do |args|
    h = change_notice_args(args)
    salutation  = h[:watcher] ? "Dear #{h[:watcher]}" : "Dear #{Card.setting :title} user"
    selfedits   = render_list_of_changes(args)
    subedits    = h[:act].actions.map do |action| 
        action.card_id == card.id ? '' : action.card.format(:format=>:email).render_subedit_notice(:action=>action)
      end.join
    return '' unless selfedits.present? or subedits.present?
      %{
#{salutation}

#{card.name}
was just <a href="#{h[:change_url]}">#{h[:edit][:action_type]}</a>
by #{h[:act].actor.name}

#{ selfedits }

#{ wrap_subedits subedits if subedits.present? }

See the card: "#{h[:card_url]}"</p>

You received this email because you're following "#{h[:watched]}". 
Visit #{h[:unwatch_url]} to stop receiving these emails.
      }
  end
  
  view :list_of_changes, :denial=>:blank do |args|
    edit = edit_info(args)
    case edit[:action_type]
    when 'created'
      %{
#{"cardtype: #{edit[:new_cardtype]}" if edit[:new_cardtype] }
#{"content: #{edit[:new_content]}"   if edit[:new_content] }
      }
    when 'updated'
      %{
        #{'the name was changed'                 if edit[:new_name] }
        #{"new cardtype: #{edit[:new_cardtype]}" if edit[:new_cardtype] }
        #{"new content: #{edit[:new_content]}"   if edit[:new_content] }
      }
    when 'deleted'
      ''
    end
  end
  
  view :subedit_notice, :denial=>:blank do |args|
    edit = edit_info(args)
    %{
      #{card.name} #{edit[:action_type]}
      #{ render_list_of_changes(args) }
    }
  end
end