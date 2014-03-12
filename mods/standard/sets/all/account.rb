module ClassMethods
  def default_accounted_type_id
    Card::UserID
  end
end

def account
  fetch :trait=>:account
end

def accountable?
  Card.toggle( rule :accountable )
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

def is_own_account?
  cardname.part_names[0].key == Account.as_card.key and
  cardname.part_names[1].key == Card[:account].key
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
    args[:buttons] = %{
      #{ submit_tag 'Invite' }
      #{ link_to 'Cancel', previous_location }      
    }
    
    %{
      #{ hidden_field_tag :success, "REDIRECT: #{success}" if success }
      #{ fieldset :subject, text_field( :email, :subject, :value=>subject, :size=>60 ) }
      #{ fieldset :message, text_area( :email, :message, :value=>message, :rows=>10, :cols => 60 ),
          :help => "We'll create a password and attach it to the email." }
      #{ _optional_render :button_fieldset, args }
    }    
  end
  
  
  view :account, :perms=> lambda { |r| r.card.update_account_ok? } do |args|
    frame_and_form :update, args, 'notify-success'=>'account details updated' do
      %{
        #{ render_account_detail }
        #{ _optional_render :button_fieldset, args }
      }
    end
  end
  
  def default_account_args args
    default_new_account_args args
    args[:buttons] = submit_tag 'Save Changes'
  end


  view :account_detail, :perms=>lambda { |r| r.card.update_account_ok? } do |args|
    account = args[:account] || card.account
    email = account.email if account
    
    %{
      #{ fieldset :email,
        text_field( 'card[account_args]', :email, :autocomplete => :off, :value=>email ),
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
        if !args[:setup] && account && Account.current_id != account.id 
          fieldset :block, check_box_tag( 'card[account_args][blocked]', '1', account.blocked? ), :help=>'prevents sign-ins'
        end
      }
    }
    
  end
  

  view :new_account, :perms=> lambda { |r| r.card.accountable? && !r.card.account } do |args|
    frame_and_form :update, args do
      %{
        #{ _render_email_fieldset    }
        #{ _render_invitation_field  }
      }
    end
  end
  
  def default_new_account_args args
    args[:hidden] = { :success => { :id=>'_self', :view=>'account' } }
  end
  
  
  view :email_fieldset do |args|
    fieldset :email, text_field( 'card[account_args]', :email ), :editor=>'content'
  end
  
  
  view :signin_and_forgot_password, :perms=>:none do |args|
    %{
      <div id="sign-in">#{ _render_signin args }</div>
      <div id="forgot-password">#{ _render_forgot_password args }</div>
    }
  end


  view :forgot_password, :perms=>:none do |args|
    args.merge!( {
      :title=>'Forgot Password',
      :optional_help=>:show, 
      :optional_menu=>:never,
      :hidden => { :success => { :view=>:forgot_password }},
      :buttons => submit_tag( 'Reset my password' )
    } )
    
    frame_and_form 'account/forgot_password', args, :recaptcha=>:off,
      'notify-success'=>"Check your email for your new temporary password" do
      [
        fieldset( :email, text_field_tag( 'email', params[:email] ) ),
        _optional_render( :button_fieldset, args )
      ]
    end
  end
end


event :set_stamper, :before=>:approve do
  self.updater_id = Account.current_id
  self.creator_id = self.updater_id if new_card?
end



=begin
event :create_account, :after=>:store, :on=>:save do
  if @account_args && !account && Card.toggle( rule :accountable )
    
    # note - following must be done here because subcard handling happens later (after mods loaded)
    # and account card must be created before user entry
    # when all are cards, neither the as_bot nor the special treatment should be necessary.
    account_card = Account.as_bot do
      Card.create! :name=>"#{ name }+#{ Card[:account].name }"
    end 
    
#    @account_args[:status] = 'pending' unless accountable?
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
      raise Card::Oops, "can't block own account"
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




event :block_deleted_user, :after=>:store, :on=>:delete do
  if account
    account.update_attributes :status=>'blocked'
  end
end
=end
