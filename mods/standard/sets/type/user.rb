# -*- encoding : utf-8 -*-

include Card::Set::Type::Basic

attr_accessor :email

#FIXME - should perms check permission to create account?
view :new do |args|
  email_params = params[:email] || {}
  subject = email_params[:subject] || Card.setting('*invite+*subject') || ''
  message = email_params[:message] || Card.setting('*invite+*message') || ''
  
  frame_args = args.merge :title=>'Invite', :show_help=>true, :hide_menu=>true
  if card.known?
    frame_args[:help_text] = "Accept account request from: #{link_to_page card.name}"
  end
  
  wrap_frame :invite, frame_args do
    card_form, :action=>params[:action] do |f|
      
      @form = f
      %{
        #{
          if !card.known?
            %{
              #{ _render_name_editor :help=>'usually first and last name' }
              #{ fieldset :email, text_field( :account, :email, :size=>60 ) }
            }
          else
            hidden_field_tag 'card[key]', card.key
          end
        }

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
  end
end
