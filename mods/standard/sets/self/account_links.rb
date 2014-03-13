# -*- encoding : utf-8 -*-
format :html do

  view :raw do |args|
    #ENGLISH
    prefix = "#{ Wagn.config.relative_url_root }/account"
    %{<span id="logging">#{
      if Account.signed_in?
        ucard = Account.current
        %{
          #{ link_to ucard.name, "#{ Wagn.config.relative_url_root }/#{ucard.cardname.url_key}", :id=>'my-card-link' }
          #{
            if Card.new(:type_id=>Card.default_accounted_type_id).ok? :create
              link_to 'Invite a Friend', "#{prefix}/invite", :id=>'invite-a-friend-link'
            end
          }
          #{ link_to 'Sign out', wagn_path('delete/:signin'), :id=>'signout-link' }
        }
      else
        %{
          #{ if Card.new(:type_id=>Card::AccountRequestID).ok? :create
               link_to 'Sign up', "#{prefix}/signup", :id=>'signup-link'
             end }
          #{ link_to 'Sign in', wagn_path(':signin'), :id=>'signin-link' }
        }
      end }
    </span>}
  end

end
