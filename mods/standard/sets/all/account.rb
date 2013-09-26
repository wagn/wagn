def create_account
  @account_args ||= {}
  account_card = fetch :trait=>:account
  @account_args.reverse_merge!({
     :card_id    => self.id,
     :status     => 'active',
     :account_id => (account_card && account_card.id)
  })
  
  warn "account_args = #{@account_args}"
  account = User.new @account_args
  account.generate_password if account.password.blank?
  unless account.save
    account.errors.each do |key,err|
      errors.add key,err
    end
    raise ActiveRecord::RecordInvalid, self
  end
end

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





end
