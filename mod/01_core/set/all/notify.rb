
format :email do
  
  def wrap_subedits subedits
    %{
      This update included the following changes
      <ul>
        #{subedits}
      </ul>
    }
  end
  
  def changes_overview
    
  end
    
  view :change_notice, :skip_permissions=>true, :denial=>:blank do |args|
    act = args[:act_id] ? Card::Act.find(args[:act_id]) : card.acts.last
    change_url  = wagn_url( "card/changes/#{card.cardname.url_key}" )
    unwatch_url = wagn_url( "card/watch/#{args[:watched].to_name.url_key}?toggle=off" )
    updater_url = wagn_url( act.actor )
    watcher     = args[:watcher]
    watched     = (args[:watched] == card.cardname ? args[:watched] : "#{args[:watched]} cards")
    edit        = act.actions.find_by_card_id(card.id).edit_info
    
    salutation = watcher ? "Dear #{watcher}" : "Dear #{Card.setting :title} user"
    
    selfedits = render_list_of_changes(args)
    subedits = if (subactions = actions.where('card_id <> ?',card.id))
      subactions.map do |action| 
        action.card.format(:format=>:email).render_subedit_notice(:action=>action)
      end.join
    end
    
    return "" unless selfedits.present? or subedits.present?
    %{
      #{salutation}
      <p>
        <a href="#{wagn_url(card)}">#{card.name}</a> 
        was just <a href="#{change_url}">#{edit[:action_type]}</a>
        by <a href="#{updater_url}">#{act.actor.name}</a>
      </p>
      
      #{ selfedits }
      
      #{ wrap_subedits subedits if subedits.present}
      
      <p>See the card: "#{wagn_url(card)}"</p>

      <p>
        You received this email because you're following "#{watched}". <br/>
        <a href="#{unwatch_url}">Unfollow</a> to stop receiving these emails.
      </p>
    }
  end
  
  view :list_of_changes, :denial=>:blank do |args|
    action = args[:action] || (args[:action_id] and Card::Action.find(args[:action_id])) || last_action
    case action.action_type
    when :create
    %{
      %{
        <ul>
        #{"<li>cardtype: #{edit[:new_cardtype]}</li>" if edit[:new_cardtype] }
        #{"<li>content: #{edit[:new_content]}</li>"   if edit[:new_content] }
        </ul>
      }
    }
    when :update
      %{
        <ul>
        #{'<li>the name was changed</li>'                 if edit[:new_name] }
        #{"<li>new cardtype: #{edit[:new_cardtype]}</li>" if edit[:new_cardtype] }
        #{"<li>new content: #{edit[:new_content]}</li>"   if edit[:new_content] }
        </ul>
      }
    when :delete
    end
  end
  
  view :subedit_notice, :denial=>:blank do |args|
    action = args[:action] || (args[:action_id] and Card::Action.find(args[:action_id])) || last_action
    edit = action.edit_info
    %{
      <li>#{edit[:new_name]} #{edit[:action_type]}
      #{ render_list_of_changes(args) }
      </li>
    }
  end
end


format :text do
  
end