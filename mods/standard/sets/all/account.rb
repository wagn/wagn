module ClassMethods
  def default_accounted_type_id
    Card::UserID
  end
end

def account
  Account[ id ]
end

def accountable?
  Card.toggle( rule(:accountable) ) and
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
  view :invitation_fields do |args|
    email_params = params[:email] || {}
    subject = email_params[:subject] || Card.setting('*invite+*subject') || ''
    message = email_params[:message] || Card.setting('*invite+*message') || ''
    
    success = Card.setting "#{ Card[:invite].name }+#{ Card[:thanks].name }"
    
    %{
      #{ hidden_field_tag :success, "REDIRECT: #{success}" if success }
      #{ fieldset :subject, text_field( :email, :subject, :value=>subject, :size=>60 ) }
      #{ fieldset :message, text_area( :email, :message, :value=>message, :rows=>10, :cols => 60 ),
          :help => "We'll create a password and attach it to the email." }
      <fieldset>
        <div class="button-area">
          #{ submit_tag 'Invite' }
          #{ link_to 'Cancel', previous_location }
        </div>
      </fieldset>
    }    
  end
  
  
  view :account, :perms=> lambda { |r| r.card.update_account_ok? } do |args|

    locals = {:slot=>self, :card=>card, :account=>card.account }
    wrap_frame :account, args do
      card_form :update, '', 'notify-success'=>'account details updated' do |form|
        %{
          #{ hidden_field_tag 'success[id]', '_self' }
          #{ hidden_field_tag 'success[view]', 'account' }
          #{ render_account_detail }
          <fieldset><div class="button-area">#{ submit_tag 'Save Changes' }</div></fieldset>
        }
      end
    end
  end


  view :account_detail, :perms=>lambda { |r| r.card.update_account_ok? } do |args|
    account = args[:account] || card.account
    
    %{
      #{ fieldset :email,
        text_field( 'card[account_args]', :email, :autocomplete => :off, :value=>account.email ),
        :editor => 'content'
      }
      #{ fieldset :password,
        password_field( 'card[account_args]', :password ),
        :help   => (args[:setup] ? nil : 'no change if blank'),
        :editor => 'content'
      }
      #{ fieldset 'confirm password',
        password_field( 'card[account_args]', :password_confirmation ),
        :editor => 'content'
      }
      #{ 
        if !args[:setup] && Account.user.id != account.id 
          fieldset :block, check_box_tag( 'card[account][blocked]', '1', account.blocked? ), :help=>'prevents sign-ins'
        end
      }
    }
    
  end
  

  view :new_account, :perms=> lambda { |r| r.card.accountable? && !r.card.account } do |args|
    wrap_frame :new_account, args do
      card_form :update do |form|
        %{
          #{ hidden_field_tag 'success[id]', '_self'                       }
          #{ hidden_field_tag 'success[view]', 'account'                   }
          #{ fieldset :email, text_field( 'card[account_args]', :email )   }
          #{ _render_invitation_field                                      }
        }
      end
    end
  end
  
  
  
  view :signin, :tags=>:unknown_ok, :perms=>:none do |args|
    frame_args = args.merge :title=>'Sign In', :show_help=>true, :optional_menu=>:never
    signin_core = wrap_frame :signin, frame_args do
      form_tag wagn_path('account/signin') do
        %{
          #{ fieldset :email, text_field_tag( 'login', params[:login], :id=>'login_field' ) }
          #{ fieldset :password, password_field_tag( 'password' ) }
          <fieldset>
            <div class="button-area">
              #{ submit_tag 'Sign in' }
              #{ link_to '...or sign up!', wagn_path('account/signup') if Card.new(:type_id=>Card::AccountRequestID).ok? :create }
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
    frame_args = args.merge :title=>'Forgot Password', :show_help=>true, :optional_menu=>:never
    wrap_frame :forgot_password, frame_args do
      form_tag wagn_path('account/forgot_password') do
        %{
          #{ fieldset :email, text_field_tag( 'email', params[:email] ) }
          <fieldset><div class="button-area">#{ submit_tag 'Reset my password' }</div></fieldset>
        }
      end
    end
  end
end


event :set_stamper, :before=>:approve do
  self.updater_id = Account.current_id
  self.creator_id = self.updater_id if new_card?
end

event :create_account, :after=>:store, :on=>:save do
  if @account_args && !account && Card.toggle( rule :accountable )
    
    # note - following must be done here because subcard handling happens later (after mods loaded)
    # and account card must be created before user entry
    # when all are cards, neither the as_bot nor the special treatment should be necessary.
    account_card = Account.as_bot do
      Card.create! :name=>"#{ name }+#{ Card[:account].name }"
    end 
    
    @account_args[:status] = 'pending' unless accountable?
    @account_args.reverse_merge! :card_id => self.id, :status => 'active', :account_id => account_card.id

    user = User.new @account_args
    handle_user_save user
    @newly_activated_account = user if user.active?
  end
end

event :update_account, :after=>:store, :on=>:update do
  if @account_args && account && update_account_ok?
    @account_args[:blocked] = account_args[:blocked] == '1'
    if Account.as_id == id and account_args[:blocked]
      raise Wagn::Oops, "can't block own account"
    end
    user = account
    user.attributes = @account_args
    handle_user_save user
  end
end

def handle_user_save user
  unless user.save
    user.errors.each do |key,err|
      errors.add key,err
    end
    raise ActiveRecord::Rollback
  end
end


activation_ready = proc do |c|
  Wagn::Env.params[:activate] and c.accountable? and c.account
end

event :activate_account, :after=>:store, :on=>:update, :when=>activation_ready do
  account.update_attributes :status=>'active'
  @newly_activated_account = account
end


event :notify_accounted, :after=>:extend do
  if @newly_activated_account && @newly_activated_account.active?
    email_args = Wagn::Env.params[:email] || {}
    email_args[:message] ||= Card.setting('*signup+*message') || "Thanks for signing up to #{Card.setting('*title')}!"
    email_args[:subject] ||= Card.setting('*signup+*subject') || "Account info for #{Card.setting('*title')}!"
    @newly_activated_account.send_account_info email_args
  end
end

event :block_deleted_user, :after=>:store, :on=>:delete do
  if account = Account[ self.id ]
    account.update_attributes :status=>'blocked'
  end
end
