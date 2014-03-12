# -*- encoding : utf-8 -*-

view :open do |args|
  args.merge!( {
    :title=>'Sign In',
    :optional_help=>:show,
#    :optional_menu=>:never,
  } )
  
  _final_open args
end

view :core do |args|
  args[:buttons] = submit_tag 'Sign in'
  if Card.new(:type_id=>Card::AccountRequestID).ok? :create
    args[:buttons] += link_to( '...or sign up!', wagn_path("new/:account_request"))
  end
  
  form_args = {
    :hidden => { :success=>'REDIRECT: /' },
    :recaptcha => :off
  }
  card_form :update, form_args do
    [
      fieldset( :email, text_field_tag( 'login', params[:login], :id=>'login_field' ) ),
      fieldset( :password, password_field_tag( 'password' ) ),
      _optional_render( :button_fieldset, args )
    ].join
  end
end

event :signin, :before=>:approve, :on=>:save do
  login, password = Wagn::Env.params[:login], Wagn::Env.params[:password]

  if signin_id = Account.authenticate( login, password )
    Account.signin signin_id
    abort :success
  else
    accted = Account[ login.strip.downcase ]
    errors.add :signin, case
      when accted.nil?             ; "Unrecognized email."
      when !accted.account.active? ; "Sorry, that account is not active."
      else                         ; "Wrong password"
      end
    abort :failure
  end
  
end

event :signout, :before=>:approve, :on=>:delete do
  Account.signin nil
  abort :success
end

