# -*- encoding : utf-8 -*-

include Card::Set::Type::Basic

attr_accessor :email

format :html do

  view :invitation_fields do |args|
    email_params = params[:email] || {}
    subject = email_params[:subject] || Card.setting('*invite+*subject') || ''
    message = email_params[:message] || Card.setting('*invite+*message') || ''
    
    success = Card.setting "#{ Card[:invite].name }+#{ Card[:thanks].name }"
    
    %{
      #{ hidden_field_tag :success, "REDIRECT: #{success}" if success }
      
      #{ fieldset :subject, text_field( :email, :subject, :value=>subject, :size=>60 ) }

      #{ fieldset :message,
          text_area( :email, :message, :value=>message, :rows=>10, :cols => 60 ),
          :help => "We'll create a password and attach it to the email."
      }
      <fieldset>
        <div class="button-area">
          #{ submit_tag 'Invite' }
          #{ link_to 'Cancel', previous_location }
        </div>
      </fieldset>
    }
    
  end

  #FIXME - should perms check permission to create account?
  view :new do |args|
    wrap_frame :invite, args.merge( :title=>'Invite', :show_help=>true, :hide_menu=>true ) do
      card_form :create do |f|      
        @form = f
        %{
          #{ _render_name_editor :help=>'usually first and last name'   }
          #{ fieldset :email, text_field( :account, :email, :size=>60 ) }
          #{ _render_invitation_field              }
        }
      end
    end
  end

end


event :create_invited_account, :after=>:store, :on=>:create do
  create_account
end

event :notify_accounted, :after=>:extend do
  if account.active?
    params = Wagn::Env[:params]  || {}
    email_args = params[:email] || {}
    email_args[:message] ||= Card.setting('*signup+*message') || "Thanks for signing up to #{Card.setting('*title')}!"
    email_args[:subject] ||= Card.setting('*signup+*subject') || "Account info for #{Card.setting('*title')}!"
    account.send_account_info email_args
  end
end
