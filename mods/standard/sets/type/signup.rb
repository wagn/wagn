
format :html do
  
  view :new do |args|
    #FIXME - make more use of standard new view
    args.merge!(
      :optional_help => :show, #, :optional_menu=>:never
      :buttons => button_tag( 'Submit' ),
      :hidden => {
        :success => (card.rule(:thanks) || '_self'),
        'card[type_id]' => card.type_id
      }
    )
      
    account = card.fetch :trait=>:account, :new=>{}

    frame_and_form :create, args, 'main-success'=>"REDIRECT" do
      [
        _render_name_fieldset( :help=>'usually first and last name' ),
        Auth.as_bot { subformat(account)._render( :content_fieldset, :structure=>true ) },  #YUCK!!!!
        ( card.structure ? edit_slot : ''),
        _optional_render( :button_fieldset, args )
      ]
    end
  end


  view :core do |args|
    #ENGLISH
    process_content(_render_raw) +
    if (card.new_card?); '' else
      %{<div class="invite-links"><strong>#{card.name}</strong> requested an account on #{format_date(card.created_at) }</div>}
    end
  end
end

event :activate_by_token, :before=>:approve, :on=>:update, :when=>proc{ |c| c.has_token? } do
  authentication_result = Auth.authenticate_by_token @env_token
  case authentication_result
  when Integer
    subcards['+*account'] = {'+*status'=>'active'}
    self.type_id = Card.default_accounted_type_id
    Auth.signin authentication_result
    Auth.as_bot
    Env.params[:success] = ''
  when :token_expired
    resend_activation_token
    abort :success
  else
    abort :failure, "signup activation error: #{authentication_result}" # bad token or account
  end
end

def has_token?
  @env_token = Env.params[:token]
end


event :resend_activation_token do
  Auth.as_bot do
    token_card = Auth.find_token_card @env_token
    token_card.update_attributes! :content => generate_token
    token_card.left.send_new_account_confirmation_email
  end
  Env.params[:success] = {
    :id => '_self',
    :view => 'message',
    :message => "Sorry, this token has expired. Please check your email for a new password reset link."
  }
end




event :preprocess_account_subcards, :before=>:process_subcards, :on=>:create do
  #FIXME: use codenames!
  email, password = subcards.delete('+*account+*email'), subcards.delete('+*account+*password')
  subcards['+*account'] ||={}
  subcards['+*account']['+*email']   = email if email
  subcards['+*account']['+*password' ]=password if password
end

send_signup_notifications = proc do |c|
  c.account and c.account.pending? and Card.setting '*request+*to'
end

event :signup_notifications, :after=>:extend, :on=>:create, :when=>send_signup_notifications do
  Mailer.signup_alert(self).deliver
end



