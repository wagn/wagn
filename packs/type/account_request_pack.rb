class Wagn::Renderer
  define_view(:naked, :type=>'account_request') do |args|
    links = [ #ENGLISH
      (link_to( "Invite #{card.name}", "/account/accept?card[key]=#{card.cardname.to_url_key}", :class=>'invitation-link') if System.ok?(:create_accounts)   ),
      (link_to_remote( "Deny #{card.name}", { :url=>url_for("card/remove") } )                    if logged_in? && card.ok?(:delete))
    ].compact
    
    process_content(_render_raw) + 
    if !card.new_card?
      div( :class=>"invite-links help instruction" ) do
        div { "<strong>#{card.name}</strong> requested an account on #{ format_date(card.created_at) }" } +
        (!links.empty? ? div { links.join } : '')
      end
    else; ''; end
  end
end

