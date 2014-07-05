include Wagn::Location

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
    headings, links = [], []
    if !card.new_card? #necessary?
      headings << %(<strong>#{ card.name }</strong> requested an account on #{ format_date card.created_at })
      if account = card.account
        if account.token
          headings << "An activation token has been sent for this account"
        else
          if account.confirm_ok?
            links << link_to( "Approve #{card.name}", wagn_path("/update/~#{card.id}?approve=true") )
          end
          if card.ok? :delete
            links << link_to( "Deny #{card.name}", wagn_path("/delete/~#{card.id}") )
          end
          headings << links * '' if links.any?
        end
      else
        headings << "ERROR: signup card missing account"
      end
    end
    %{<div class="invite-links">
        #{ headings.map { |h| "<div>#{h}</div>"} * "\n" }
      </div>
      #{ process_content render_raw }    
    }
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


event :approve_account, :on=>:update, :before=>:process_subcards, :when=>proc {|c| Env.params[:approve] } do
  account.reset_token
  account.send_account_confirmation_email
end


event :resend_activation_token do
  account = Auth.find_token_card( @env_token ).left
  account.reset_token
  account.send_account_confirmation_email
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
  args =  {
    :to     => Card.setting('*request+*to'),
    :from   => Card.setting('*request+*from') || "#{@name} <#{@email}>",
    :locals => {
      :email        => self.account.email,
      :name         => self.name,
      :request_url  => wagn_url( self ),
      :requests_url => wagn_url( Card[:signup] ),
  }
  }
  Card['signup alert'].format(:format=>:email).deliver(args)
end

