class Wagn::Renderer
  define_view(:raw, :name=>'*account links') do |args|
    #ENGLISH
    prefix = System.root_path + '/account'
    %{<span id="logging">#{
      if User.logged_in?
        ucard = User.current_user.card
        link_to( "My Card: #{ucard.name}", "#{System.root_path}/wagn/#{ucard.cardname.to_url_key}", :id=>'my-card-link') +
        (System.ok?(:create_accounts) ? link_to('Invite a Friend', "#{prefix}/invite", :id=>'invite-a-friend-link') : '') +
        link_to('Sign out', "#{prefix}/signout", :id=>'signout-link')
      else
        (Card.new(:typecode=>'InvitationRequest').ok?(:create) ? link_to( 'Sign up', "#{prefix}/signup",   :id=>'signup-link' ) : '') +
        link_to( 'Sign in', "#{prefix}/signin",   :id=>'signin-link' )
      end }
    </span>}
  end
  alias_view(:raw, {:name=>'*account link'}, :core)
end
