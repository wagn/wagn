
format :html do
  
  view :new do |args|
    #FIXME - make more use of standard new view
    args.merge!(
      :optional_help => :show, #, :optional_menu=>:never
      :buttons => submit_tag( 'Submit' ),
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

event :activate_by_token, :before=>:approve, :on=>:update do
  if token = Env.params[:token]
    if id == Auth.authenticate_by_token(token)
      subcards['+*account'] = {'+*status'=>'active'}
      self.type_id = Card.default_accounted_type_id
      Auth.signin id #move this to extend?
      Auth.as_bot
      Env.params[:success] = ''
    else
      abort :failure
    end
  end
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



