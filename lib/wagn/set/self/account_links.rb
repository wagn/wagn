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
          %{#{   link_to ucard.name, "#{Wagn::Conf[:root_path]}/#{ucard.cardname.url_key}", :id=>'my-card-link'
             }#{ if invite_card = Card[:account].fetch(:trait=>:invite) and invite_card.ok? :create
                   link_to 'Invite a Friend', invite_card.key, :id=>'invite-a-friend-link'
                 end
             }#{ link_to 'Sign out', Card[:session].key, :method=>'DELETE',           :id=>'signout-link'
           }}
         else
           %{#{ if (signup_card = Card[:account].fetch :trait=>:signup).send_if :ok?, :create
                 link_to 'Sign up', signup_card.key, :id=>'signup-link'
                end
            }#{ link_to 'Sign in', Card[:session].key, :id=>'signin-link'
            }}
         end }
      </span>}
    end
  end
end
