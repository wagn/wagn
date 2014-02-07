# -*- encoding : utf-8 -*-

include Card::Set::Type::Basic

attr_accessor :email

format :html do
  #FIXME - should perms check permission to create account?
  view :new do |args|
    args.merge!(
      :title=>'Invite', 
      :optional_help=>:show, 
      :optional_menu=>:never 
    )
    
    frame_and_form :invite, :create, args do
      %{
        #{ form.hidden_field :type_id }
        #{ _render_name_fieldset :help=>'usually first and last name'   }
        #{ _render_email_fieldset                                       }
        #{ _render_invitation_field                                     }
      }
    end
  end

end

