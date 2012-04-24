class Wagn::Renderer
  define_view :core, :type=>:invitation_request do |args|
    links = []
    #ENGLISH
    if Card[Card::Codename[:account]].ok?(:create)
      links << link_to( "Invite #{card.name}", Card.path_setting("/account/accept?card[key]=#{card.cardname.to_url_key}"), :class=>'invitation-link')
    end
    if Card.logged_in? && card.ok?(:delete)
      links << link_to( "Deny #{card.name}", path(:remove), :class=>'slotter standard-delete', :remote=>true )
    end
    
    process_content(_render_raw) + 
    if (card.new_card?); '' else 
      %{<div class="invite-links help instruction">
          <div><strong>#{card.name}</strong> requested an account on #{format_date(card.created_at) }</div>
          #{%{<div>#{links.join('')}</div> } unless links.empty? }
      </div>}
    end
  end
end

