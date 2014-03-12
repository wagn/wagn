# -*- encoding : utf-8 -*-

include Card::Set::Type::Basic

attr_accessor :email

format :html do
  #FIXME - should perms check permission to create account?
  view :new do |args|
    args.merge!(
      :title=>'Invite', 
      :optional_help=>:show, 
      :optional_menu=>:never 
    )
    args[:hidden].merge! :card => { :type_id => card.type_id }
    frame_and_form :create, args do
      %{
        #{ _render_name_fieldset :help=>'usually first and last name'   }
        #{# _render_email_fieldset                                       
        }
        #{# _render_invitation_field                                     
        }
      }
    end
  end


  view :setup, :tags=>:unknown_ok, :perms=>lambda { |r| Account.no_logins? } do |args|
    args.merge!( {
      :title=>'Welcome, Wagneer!',
      :optional_help=>:show,
      :optional_menu=>:never, 
      :help_text=>'To get started, set up an account.',
      :buttons => submit_tag( 'Create' ),
      :hidden => { 
        :success => "REDIRECT: #{ Card.path_setting '/' }",
        'card[type_id]' => Card.default_accounted_type_id,
        'setup'=>true
      }
    } )

    account = card.fetch :trait=>:account, :new=>{}

    Account.as_bot do
      frame_and_form :create, args, :recaptcha=>:off do
        [
          _render_name_fieldset( :help=>'usually first and last name' ),
          subformat(account)._render( :content_fieldset, :structure=>true ), 
          _render_button_fieldset( args )
        ]
      end
    end
  end
end


event :setup_as_bot, :before=>:check_permissions, :on=>:create, :when=>proc{ |c| Wagn::Env.params[:setup] } do
  abort :failure unless Account.no_logins?
  Account.as_bot
end  

event :setup_first_user, :before=>:process_subcards, :on=>:create, :when=>proc{ |c| Wagn::Env.params[:setup] } do
  email, password = subcards.delete('+*account+*email'), subcards.delete('+*account+*password')
  subcards['+*account'   ] = { '+*email'=>email, '+*password'=>password }
  subcards['+*roles'     ] = { :content => Card[:administrator].name }
  subcards['*request+*to'] = email
end

event :signin_after_setup, :before=>:extend, :on=>:create, :when=>proc{ |c| Wagn::Env.params[:setup] } do
  Card.cache.delete 'no_logins'
  Account.signin id
end


