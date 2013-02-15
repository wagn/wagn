module Wagn
  module Set::Self::AccountLinks
    include Wagn::Sets

    format :html

    define_view :raw, :name=>:account_links do |args|
      #ENGLISH
      prefix = Wagn::Conf[:root_path] + '/account'
      %{<span id="logging">#{
        if Account.logged_in?
          ucard = Account.user_card
          %{
            #{ link_to ucard.name, "#{Wagn::Conf[:root_path]}/#{ucard.cardname.url_key}", :id=>'my-card-link' }
            #{ if Card[:account].ok? :create
                 link_to 'Invite a Friend', "#{prefix}/invite", :id=>'invite-a-friend-link'
               end }
            #{ link_to 'Sign out', "#{prefix}/signout",                                      :id=>'signout-link' }
          }
        else
          %{
            #{ if Card.new(:typecode=>'account_request').ok? :create
                 link_to 'Sign up', "#{prefix}/signup", :id=>'signup-link'
               end }
            #{ link_to 'Sign in', "#{prefix}/signin", :id=>'signin-link' }
          }
        end }
      </span>}
    end
  end
end
