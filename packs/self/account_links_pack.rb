class Wagn::Renderer
  define_view(:raw, :name=>'*account links') do |args|
    #ENGLISH
    prefix = System.root_path + '/account'
    span(:id=>'logging') do
      if User.logged_in?
        link_to( "My Card: #{User.current_user.card.name}", '/me', :id=>'my-card-link') +
        (System.ok?(:create_accounts) ? link_to('Invite a Friend', "#{prefix}/invite", :id=>'invite-a-friend-link') : '') +
        link_to('Sign out', "#{prefix}/signout", :id=>'signout-link')
      else
        (Card.new(:typecode=>'InvitationRequest').ok?(:create) ? link_to( 'Sign up', "#{prefix}/signup",   :id=>'signup-link' ) : '') +
        link_to( 'Sign in', "#{prefix}/signin",   :id=>'signin-link' )
      end
    end
  end
  alias_view(:raw, {:name=>'*account link'}, :core)
end
