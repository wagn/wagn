def consider_recaptcha?
  false
end

format :html do
  view :open do
    voo.show! :help
    super()
  end

  # FIXME: need a generic solution for this
  view :title do
    voo.title ||= I18n.t(:sign_in_title, scope: "mod.standard.set.self.signin")
    super()
  end

  view :open_content do
    # annoying step designed to avoid table of contents.  sigh
    _render_core
  end

  view :closed_content do
    ""
  end

  view :core do
    voo.structure = true
    with_nest_mode :edit do
      card_form :update, recaptcha: :off do
        [hidden_signin_fields,
         content_formgroup,
         signin_buttons].join
      end
    end
  end

  def hidden_signin_fields
    hidden_field_tag :success,
                     "REDIRECT: #{Env.interrupted_action || '*previous'}"
  end


  def signin_buttons
    button_formgroup do
      [signin_button, signup_link, reset_password_link]
    end
  end

  def signin_button
    text = I18n.t :sign_in, scope: "mod.standard.set.self.signin"
    button_tag text, situation: "primary"
  end

  def signup_link
    text = I18n.t :or_sign_up, scope: "mod.standard.set.self.signin"
    subformat(Card[:account_links]).render :sign_up, title: text
  end

  def reset_password_link
    text = I18n.t :reset_password, scope: "mod.standard.set.self.signin"
    reset_link = link_to_view :edit, text, path: { slot: { hide: :toolbar } }
    # FIXME: inline styling
    raw("<div style='float:right'>#{reset_link}</div>")
  end

  # FORGOT PASSWORD
  view :edit do
    @forgot_password = true
    voo.title ||= card.i18n_signin(:forgot_password)
    voo.structure ||= true
    voo.hide! :help
    Auth.as_bot { super() }
  end

  def hidden_edit_fields
    hidden_tags(
      reset_password: true,
      success: { view: :reset_password_success }
    )
  end

  def edit_buttons
    text = I18n.t :reset_my_password, scope: "mod.standard.set.self.signin"
    button_tag text, situation: "primary"
  end

  def nested_fields
    fields = [["".to_name.trait(:email),
               { view: "titled", title: "email", skip_permissions: true }]]
    unless @forgot_password
      fields << ["".to_name.trait(:password),
                 { view: "titled", title: "password", skip_permissions: true }]
    end
    fields
  end

  view :reset_password_success do
    # 'Check your email for a link to reset your password'
    frame { I18n.t(:check_email, scope: "mod.standard.set.self.signin") }
  end
end

event :signin, :validate, on: :update do
  email = subfield :email
  email &&= email.content
  pword = subfield :password
  pword &&= pword.content

  authenticate_or_abort email, pword
end

def authenticate_or_abort email, pword
  abort :failure, i18n_signin(:abort_bad_signin_args) unless email && pword
  if (account = Auth.authenticate(email, pword))
    Auth.signin account.left_id
  else
    account = Auth.find_account_by_email email
    errors.add :signin, signin_error_message(account)
    abort :failure
  end
end

def signin_error_message account
  case
  when account.nil?     then i18n_signin(:error_unknown_email)
  when !account.active? then i18n_signin(:error_not_active)
  else                       i18n_signin(:error_wrong_password)
  end
end

def i18n_signin key
  I18n.t key, scope: "mod.standard.set.self.signin"
end

event :signin_success, after: :signin do
  abort :success
end

event :send_reset_password_token, before: :signin, on: :update,
                                  when: proc { Env.params[:reset_password] } do
  email = subfield :email
  email &&= email.content

  account = Auth.find_account_by_email email
  send_reset_password_email_or_fail account
end

def send_reset_password_email_or_fail account
  if account && account.active?
    account.send_reset_password_token
    abort :success
  elsif account
    errors.add :account, i18n_signin(:error_not_active)
  else
    errors.add :email, i18n_signin(:error_not_recognized)
  end
  abort :failure
end

event :signout, :validate, on: :delete do
  Auth.signin nil
  abort :success
end
