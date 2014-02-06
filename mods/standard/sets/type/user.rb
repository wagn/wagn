# -*- encoding : utf-8 -*-

include Card::Set::Type::Basic

attr_accessor :email

format :html do
  #FIXME - should perms check permission to create account?
  view :new do |args|
    frame :invite, args.merge( :title=>'Invite', :show_help=>true, :optional_menu=>:never ) do
      card_form :create do |f|
        %{
          #{ f.hidden_field :type_id }
          #{ _render_name_fieldset :help=>'usually first and last name'   }
          #{ fieldset :email, text_field( 'card[account_args]', :email, :size=>60 ) }
          #{ _render_invitation_field                                   }
        }
      end
    end
  end

end

