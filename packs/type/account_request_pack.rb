class Wagn::Renderer
  define_view(:core, :type=>'account_request') do |args|
    links = []
    #ENGLISH
    if System.ok? :create_accounts
      links << link_to( "Invite #{card.name}", "/account/accept?card[key]=#{card.cardname.to_url_key}", :class=>'invitation-link')
    end
    if User.logged_in? && card.ok?(:delete)
      links << link_to( "Deny #{card.name}", path(:remove), :class=>'standard-slotter standard-delete', :remote=>true )
    end
    
    process_content(_render_raw) + 
    card.new_card? ? '' : %{<div class="invite-links help instruction>
        <div><strong>#{card.name}</strong> requested an account on #{
          format_date(card.created_at) }"</div>#{
        %{<div>#{links*''}</div> } unless links.empty? }
      </div>}
  end
end

