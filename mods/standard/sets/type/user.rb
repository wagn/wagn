# -*- encoding : utf-8 -*-

include Card::Set::Type::Basic

attr_accessor :email

format :html do
  #FIXME - should perms check permission to create account?
  view :new do |args|
    wrap_frame :invite, args.merge( :title=>'Invite', :show_help=>true, :hide_menu=>true ) do
      card_form :create do |f|      
        @form = f
        %{
          #{ _render_name_editor :help=>'usually first and last name'   }
          #{ fieldset :email, text_field( :account, :email, :size=>60 ) }
          #{ _render_invitation_field                                   }
        }
      end
    end
  end

end

