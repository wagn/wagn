
format :html do
  view :open do |args|
    args[:optional_help] = :show
    super args
  end

  def default_title_args args
    args[:title] ||= I18n.t(:sign_in_title, # 'Sign In'
                            scope: "mod.05_standard.set.self.signin")
  end

  view :open_content do |args|
    # annoying step designed to avoid table of contents.  sigh
    _render_core(args)
  end

  view :closed_content do |_args|
    ""
  end

  def default_core_args args={}
    # 'Sign in' '...or sign up!' 'RESET PASSWORD'
    sign_in, or_sign_up, reset_password =
      I18n.t([:sign_in, :or_sign_up, :reset_password],
             scope: "mod.05_standard.set.self.signin")
    # since i18n-tasks doesn't understand bulk lookups, tell it keys are used
    # i18n-tasks-use t(:sign_in, scope: 'mod.05_standard.set.self.signin')
    # i18n-tasks-use t(:or_sign_up, scope: 'mod.05_standard.set.self.signin')
    # i18n-tasks-use t(:reset_password, scope: 'mod.05_standard.set.self.signin')
    args[:buttons] = button_tag sign_in, situation: "primary"
    if Card.new(type_id: Card::SignupID).ok? :create
      args[:buttons] += link_to(or_sign_up, card_path("account/signup"))
    end
    args[:buttons] += raw(
      "<div style='float:right'>" \
      "#{view_link reset_password, :edit,
                   path_opts: { slot: { hide: :toolbar } }}" \
      "</div>") # FIXME: hardcoded styling
    args
  end

  view :core do |args|
    form_args = {
      hidden: { success: "REDIRECT: #{Env.interrupted_action || '*previous'}" },
      recaptcha: :off
    }
    with_nest_mode :edit do
      card_form :update, form_args do
        [
          _optional_render(:content_formgroup, args.merge(structure: true)),
          _optional_render(:button_formgroup, args)
        ].join
      end
    end
  end

  # FORGOT PASSWORD
  view :edit do |args|
    @forgot_password = true
    args.merge!(
      title: I18n.t(:forgot_password, # 'Forgot Password'
                    scope: "mod.05_standard.set.self.signin"),
      optional_help: :hide,
      buttons: button_tag(I18n.t(:reset_my_password, # 'Reset my password'
                                 scope: "mod.05_standard.set.self.signin"),
                          situation: "primary"),
      structure: true,
      hidden: {
        reset_password: true,
        success: { view: :reset_password_success }
      }
    )
    Auth.as_bot { super args }
  end

  view :raw do |_args|
    if @forgot_password
      "{{+#{Card[:email].name}|title:email;type:Phrase}}"
    else
      %(
        {{+#{Card[:email].name}|titled;title:email}}
        {{+#{Card[:password].name}|titled;title:password}}
      )
    end
  end

  view :reset_password_success do |_args|
    # 'Check your email for a link to reset your password'
    frame { I18n.t(:check_email, scope: "mod.05_standard.set.self.signin") }
  end
end

event :signin, :validate, on: :update do
  email = subfield :email
  email &&= email.content
  pword = subfield :password
  pword &&= pword.content

  unless email && pword
    abort :failure, I18n.t(:abort_bad_signin_args, # 'bad signin args'
                           scope: "mod.05_standard.set.self.signin")
  end

  if (account = Auth.authenticate(email, pword))
    Auth.signin account.left_id
  else
    account = Auth[email.strip.downcase]
    error_msg =
      case
      when account.nil?     then
        # 'Unrecognized email.'
        I18n.t(:error_unknown_email, scope: "mod.05_standard.set.self.signin")
      when !account.active? then
        # 'Sorry, that account is not active.'
        I18n.t(:error_not_active, scope: "mod.05_standard.set.self.signin")
      else
        # 'Wrong password'
        I18n.t(:error_wrong_password, scope: "mod.05_standard.set.self.signin")
      end
    errors.add :signin, error_msg
    abort :failure
  end
end

event :signin_success, after: :signin do
  abort :success
end

event :send_reset_password_token,
      before: :signin, on: :update,
      when: proc { Env.params[:reset_password] } do
  email = subfield :email
  email &&= email.content

  account = Auth[email.strip.downcase]
  if account
    if account.active?
      account.send_reset_password_token
      abort :success
    else
      errors.add :account, I18n.t(:error_not_active, # 'not active'
                                  scope: "mod.05_standard.set.self.signin")
      abort :failure
    end
  else
    errors.add :email, I18n.t(:error_not_recognized, # 'not recognized'
                              scope: "mod.05_standard.set.self.signin")
    abort :failure
  end
end

event :signout, :validate, on: :delete do
  Auth.signin nil
  abort :success
end
