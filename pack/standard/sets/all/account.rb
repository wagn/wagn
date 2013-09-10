def account
  Account[ id ]
end

def accountable?
  Card.toggle( rule(:accountable) ) and
  !account and
  fetch( :trait=>:account, :new=>{} ).ok?( :create)
end

def parties
  @parties ||= (all_roles << self.id).flatten.reject(&:blank?)
end

def among? card_with_acct
  card_with_acct.each do |auth|
    return true if parties.member? auth
  end
  card_with_acct.member? Card::AnyoneID
end

def read_rules
  @read_rules ||= begin
    rule_ids = []
    unless id==Card::WagnBotID # always_ok, so not needed
      ( [ Card::AnyoneID ] + parties ).each do |party_id|
        if rule_ids_for_party = self.class.read_rule_cache[ party_id ]
          rule_ids += rule_ids_for_party
        end
      end
    end
    rule_ids
  end
end

def all_roles
  @all_roles ||= 
    if id == Card::AnonID
      []
    else
      Account.as_bot do
        role_trait = fetch :trait=>:roles
        [ Card::AuthID ] + ( role_trait ? role_trait.item_ids : [] )
      end
    end
end



format :html do
  view :signin, :tags=>:unknown_ok, :perms=>:none do |args|
    frame_args = args.merge :title=>'Sign In', :show_help=>true, :hide_menu=>true
    signin_core = wrap_frame :signin, frame_args do
      form_tag wagn_path('account/signin') do
        %{
          #{ fieldset :email, text_field_tag( 'login', params[:login], :id=>'login_field' ) }
          #{ fieldset :password, password_field_tag( 'password' ) }
          <fieldset>
            <div class="button-area">
              #{ submit_tag 'Sign in' }
              #{ link_to '...or sign up!', wagn_path('/account/signup') if Card.new(:type_id=>Card::AccountRequestID).ok? :create }
            </div>
          </fieldset>
        }
      end
    end
    %{
      <div id="sign-in">#{signin_core}</div>
      <div id="forgot-password">#{_render_forgot_password}</div>
    }
  end


  view :forgot_password, :perms=>:none do |args|
    frame_args = args.merge :title=>'Forgot Password', :show_help=>true, :hide_menu=>true
    wrap_frame :forgot_password, frame_args do
      form_tag wagn_path('account/forgot_password') do
        %{
          #{ fieldset :email, text_field_tag( 'email', params[:email] ) }
          <fieldset><div class="button-area">#{ submit_tag 'Reset my password' }</div></fieldset>
        }
      end
    end
  end

  view :signup, :tags=>:unknown_ok, :perms=>:none do |args|
    frame_args = args.merge :title=>'Sign Up', :show_help=>true, :hide_menu=>true
    frame_args[:help_text] = case
      when card.rule_card( :add_help, :fallback=>:help ) ; nil
      when Account.create_ok?                            ; 'Send us the following, and we\'ll send you a password.' 
      else                                               ; 'All Account Requests are subject to review.'
      end

    wrap_frame :signup, frame_args do
      form_for :card, form_opts( wagn_path( '/account/signup' ), 'card-form') do |f|
        @form = f
        %{
          #{ f.hidden_field :type_id }
          #{ _render_name_editor :help=>'usually first and last name' }
          #{ fieldset :email, text_field( :account, :email ) }
          #{ with_inclusion_mode(:new) { edit_slot :label=>'other' } }

          <fieldset><div class="button-area">#{ submit_tag 'Submit' }</div></fieldset>
        }
      end
    end
  end

  view :invite, :tags=>:unknown_ok do |args|
    email_params = params[:email] || {}
    subject = email_params[:subject] || Card.setting('*invite+*subject') || ''
    message = email_params[:message] || Card.setting('*invite+*message') || ''
    
    frame_args = args.merge :title=>'Invite', :show_help=>true, :hide_menu=>true
    if card.known?
      frame_args[:help_text] = "Accept account request from: #{link_to_page card.name}"
    end
    
    wrap_frame :invite, frame_args do
      form_for :card, :action=>params[:action] do |f|
        
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

          #{render_error}
        }
      end
    end
  end

end
