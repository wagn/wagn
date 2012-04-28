class Wagn::Renderer
  define_view :raw, :name=>'account_link' do |args|
    #ENGLISH
    prefix = Wagn::Conf[:root_path] + '/account'
    %{<span id="logging">#{
      if Card.logged_in?
        ucard = Card.user_card
        link_to( ucard.name, "#{Wagn::Conf[:root_path]}/#{ucard.cardname.to_url_key}", :id=>'my-card-link') +
        (Card[:account].ok?(:create) ? link_to('Invite a Friend', "#{prefix}/invite", :id=>'invite-a-friend-link') : '') +
        link_to('Sign out', "#{prefix}/signout", :id=>'signout-link')
      else
        (Card.new(:typecode=>'invitation_request').ok?(:create) ? link_to( 'Sign up', "#{prefix}/signup",   :id=>'signup-link' ) : '') +
        link_to( 'Sign in', "#{prefix}/signin",   :id=>'signin-link' )
      end }
    </span>}
  end
end
