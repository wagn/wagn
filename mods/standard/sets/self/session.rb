# -*- encoding : utf-8 -*-

view :open, :perms=>:none do |args|
  args.merge!( {
    :title=>'Sign In',
    :optional_help=>:show,
#    :optional_menu=>:never,
    :hidden=>{ :success=>'REDIRECT:*previous' },
    :buttons=> submit_tag( 'Sign in' ) 
  })
  if Card.new(:type_id=>Card::AccountRequestID).ok? :create
    args[:buttons] += link_to( '...or sign up!', wagn_path("new/:account_request"))
  end
  
  _final_open args
end

view :core, :perms=>:none do |args|  
  card_form :update, :recaptcha=>:off do
    [
      fieldset( :email, text_field_tag( 'login', params[:login], :id=>'login_field' ) ),
      fieldset( :password, password_field_tag( 'password' ) ),
      _optional_render( :button_fieldset, args )
    ].join
  end
end

event :authenticate_password, :before=>:approve do
  login, password = Wagn::Env.params[:login], Wagn::Env.params[:password]

  if Wagn::Env[:controller].send 'current_account_id=', Account.authenticate( login, password )
#    flash[:notice] = "Successfully signed in"
  else
    usr=Account[ params[:login].strip.downcase ]
    @card.errors.add :signin, case
      when usr.nil?     ; "Unrecognized email."
      when usr.blocked? ; "Sorry, that account is blocked."
      else              ; "Wrong password"
      end
  end
  raise Card::Cancel
end

