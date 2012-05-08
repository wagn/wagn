class Wagn::Renderer
  define_view :raw, :name=>'*account links' do |args|
    #ENGLISH
    prefix = Wagn::Conf[:root_path] + '/account'
    %{<span id="logging">#{
      if User.logged_in?
        ucard = User.current_user.card
        %{ 
          #{ link_to ucard.name, "#{Wagn::Conf[:root_path]}/#{ucard.cardname.to_url_key}", :id=>'my-card-link' }
          #{ if User.ok? :create_accounts
               link_to 'Invite a Friend', "#{prefix}/invite", :id=>'invite-a-friend-link'
             end }
          #{ link_to 'Sign out', "#{prefix}/signout",                                      :id=>'signout-link' }
        }
      else
        %{
          #{ if Card.new(:typecode=>'InvitationRequest').ok? :create
               link_to 'Sign up', "#{prefix}/signup", :id=>'signup-link'
             end }
          #{ link_to 'Sign in', "#{prefix}/signin", :id=>'signin-link' }
        }
      end }
    </span>}
  end
  alias_view(:raw, {:name=>'*account link'}, :core)
end
