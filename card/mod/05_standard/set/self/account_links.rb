
format :html do

  def account_links
    #ENGLISH
    links = []
    if Auth.signed_in?
      links << card_link( Auth.current.cardname, :id=>'my-card-link' )
      if Card.new(:type_id=>Card.default_accounted_type_id).ok? :create
        # Shouldn't these use the new paths?
        links << link_to( 'Invite', card_path('account/signup'), :id=>'invite-a-friend-link' )
      end
      links << link_to( 'Sign out', card_path('delete/:signin'), :id=>'signout-link' )
    else
      if Card.new(:type_id=>Card::SignupID).ok? :create
        links << link_to( 'Sign up', card_path('account/signup'), :id=>'signup-link' )
      end
      links << link_to( 'Sign in', card_path(':signin'), :id=>'signin-link' )
    end
    links
  end
  
  view :raw do |args|
    %{<span id="logging">#{ account_links.join ' ' }</span>}
  end

end
