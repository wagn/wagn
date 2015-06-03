
include Basic

attr_accessor :email

format :html do

  view :setup, :tags=>:unknown_ok, :perms=>lambda { |r| Auth.needs_setup? } do |args|
    help_text = '<h3>To get started, set up an account.</h3>'
    warning = ''
    if Card.config.action_mailer.perform_deliveries == false
      warning += "<li class='list-group-item list-group-item-warning'>Email delivery is turned off. Change settings in config/application.rb to send sign up notifications.</li>"
    end
    if Card.config.recaptcha_public_key == Card::Auth::DEFAULT_RECAPTCHA_SETTINGS[:recaptcha_public_key]
      warning +=  "<li class='list-group-item list-group-item-warning'>" + process_content(
                     "You are using Wagn's default recaptcha key.
                      That's fine for a local installation.
                      If you want to use recaptchas for a publicly available Wagn installation
                      you have to register your domain at http://google.com/recaptcha and
                      add your keys to [[*recaptcha settings]].") + "</li>"
    end
    if warning.present?
      help_text += content_tag :div, :class=>"alert alert-warning alert-dismissible", :role=>"alert" do
        %{
          <button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>
          <h6>WARNING</h6>
          <ul class="list-group">#{warning}</ul>
        }.html_safe
      end
    end
    args.merge!( {
      :title=>'Welcome, Wagneer!',
      :optional_help=>:show,
      :optional_menu=>:never,
      :help_text=>help_text,
      :buttons => button_tag( 'Set up', :disable_with=>'Setting up', :situation=>'primary' ),
      :hidden => {
        :success => "REDIRECT: #{ Card.path_setting '/' }",
        'card[type_id]' => Card.default_accounted_type_id,
        'setup'=>true
      }
    } )

    account = card.fetch :trait=>:account, :new=>{}

    Auth.as_bot do
      frame_and_form :create, args do
        [
          _render_name_formgroup( :help=>'usually first and last name' ),
          subformat(account)._render( :content_formgroup, :structure=>true ),
          _render_button_formgroup( args )
        ]
      end
    end
  end
end


event :setup_as_bot, :before=>:check_permissions, :on=>:create, :when=>proc{ |c| Card::Env.params[:setup] } do
  abort :failure unless Auth.needs_setup?
  Auth.as_bot
  # we need bot authority to set the initial administrator roles
  # this is granted and inspected here as a separate event for
  # flexibility and security when configuring initial setups
end

event :setup_first_user, :before=>:process_subcards, :on=>:create, :when=>proc{ |c| Card::Env.params[:setup] } do
  subcards['signup alert email+*to'] = name
  subcards['+*roles'] = { :content => Card[:administrator].name }

  email, password = subcards.delete('+*account+*email'), subcards.delete('+*account+*password')
  subcards['+*account'] = { '+*email'=>email, '+*password'=>password }
end

event :signin_after_setup, :before=>:extend, :on=>:create, :when=>proc{ |c| Card::Env.params[:setup] } do
  Card.cache.delete Auth::NEED_SETUP_KEY
  Auth.signin id
end

def follow follow_name, option = '*always'
  if (card = Card.fetch(follow_name)) && (set_card = card.default_follow_set_card)
    if (follow_rule = Card.fetch(set_card.follow_rule_name(name), :new=>{}))
      follow_rule.drop_item "*never"
      follow_rule.add_item option
      follow_rule.save!
    end
  end
end


