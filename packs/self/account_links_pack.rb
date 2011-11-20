class Wagn::Renderer
  define_view(:raw, :name=>'*account links') do |args|
    #ENGLISH
    span(:id=>'logging') do
      if User.logged_in?
        link_to( "My Card: #{User.current_user.card.name}", '/me', :id=>'my-card-link') +
        (System.ok?(:create_accounts) ? link_to('Invite a Friend', '/account/invite', :id=>'invite-a-friend-link') : '') +
        link_to('Sign out', '/account/signout', :id=>'signout-link')
      else
        (Card.new(:typecode=>'InvitationRequest').ok?(:create) ? link_to( 'Sign up', '/account/signup',   :id=>'signup-link' ) : '') +
        link_to( 'Sign in', '/account/signin',   :id=>'signin-link' )
      end
    end
  end
  alias_view(:raw, {:name=>'*account link'}, :core)
end
