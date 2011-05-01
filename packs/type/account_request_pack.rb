class Renderer
  define_view(:naked, :type=>'account_request') do
    links = [ #ENGLISH
      (link_to( "Invite #{card.name}", "/account/accept/#{card.key}/", :class=>'invitation-link') if System.ok?(:create_accounts)   ),
      (link_to_remote( "Deny #{card.name}", { :url=>url_for("card/remove") } )                    if logged_in? && card.ok?(:delete))
    ].compact
    
    process_content(_render_raw) + 
    if !card.new_card? # this if is not really necessary yet, but conceptually correct
      div( :class=>"invite-links help instruction" ) do
        div { "<strong>#{card.name}</strong> requested an account on #{ format_date(card.created_at) }" } +
        (!links.empty? ? div { links.join } : '')
      end
    end
  end
end

