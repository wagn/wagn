
include All::Permissions::Accounts

card_accessor :email
card_accessor :password
card_accessor :salt
card_accessor :status
card_accessor :token

def active?
  status == "active"
end

def blocked?
  status == "blocked"
end

def built_in?
  status == "system"
end

def pending?
  status == "pending"
end

def validate_token! test_token
  tcard = token_card
  tcard.validate! test_token
  copy_errors tcard
  errors.empty?
end

format do
  view :verify_url do
    signup_name = card.cardname.left_name
    card_url "update/#{signup_name.url_key}" \
             "?token=#{card.token}" \
             "&live_token=true"
  end

  view :verify_days do
    (Card.config.token_expiry / 1.day).to_s
  end

  view :reset_password_url do
    card_url "update/#{card.cardname.url_key}" \
             "?token=#{card.token_card.refresh(true).content}" \
             "&live_token=true&event=reset_password"
  end

  view :reset_password_days do
    (Card.config.token_expiry / 1.day).to_s
  end
end

format :html do
  view :raw do |args|
    content = []
    unless args[:no_email]
      content << "{{+#{Card[:email].name}|titled;title:email}}"
    end
    unless args[:no_password]
      content << "{{+#{Card[:password].name}|titled;title:password}}"
    end
    content * " "
  end

  view :edit do |args|
    args[:structure] = true
    super args
  end
end

event :validate_accountability, :prepare_to_validate, on: :create do
  unless left && left.accountable?
    errors.add :content, "not allowed on this card"
  end
end

event :require_email, :prepare_to_validate,
      after: :validate_accountability, on: :create do
  errors.add :email, "required" unless subfield(:email)
end

event :set_default_salt, :prepare_to_validate, on: :create do
  salt = Digest::SHA1.hexdigest "--#{Time.zone.now}--"
  Env[:salt] = salt # HACK!!! need viable mechanism to get this to password
  add_subfield :salt, content: salt
end

event :set_default_status, :prepare_to_validate, on: :create do
  default_status = Auth.needs_setup? ? "active" : "pending"
  add_subfield :status, content: default_status
end

def confirm_ok?
  Card.new(type_id: Card.default_accounted_type_id).ok? :create
end

event :generate_confirmation_token, :prepare_to_store,
      on: :create,
      when: proc { |c| c.confirm_ok? } do
  add_subfield :token, content: generate_token
end

event :reset_password,
      :prepare_to_validate, on: :update, when: proc { |c| c.reset_password? } do
  if validate_token! @env_token
    token_card.used!
    Auth.signin left_id
    success << edit_password_success_args
  else
    error_msg = errors.first.last
    send_reset_password_token
    msg = "Sorry, #{error_msg}. " \
          "Please check your email for a new password reset link."
    success << { id: "_self", view: "message", message: msg }
  end
  abort :success
end

def edit_password_success_args
  {
    id: left.name,
    view: :related,
    related: { name: "+#{Card[:account].name}", view: "edit" }
  }
end

def reset_password?
  @env_token = Env.params[:token]
  @env_token && Env.params[:event] == "reset_password"
end

event :reset_token do
  Auth.as_bot do
    token_card.update_attributes! content: generate_token
  end
end

event :send_welcome_email do
  welcome = Card["welcome email"]
  if welcome && welcome.type_code == :email_template
    welcome.deliver context: left, to: email
  end
end

event :send_account_verification_email, :integrate,
      on: :create, when: proc { |c| c.token.present? } do
  Card[:verification_email].deliver context: self, to: email
end

event :send_reset_password_token do
  Auth.as_bot do
    token_card.update_attributes! content: generate_token
  end
  Card[:password_reset_email].deliver context: self, to: email
end

def ok_to_read
  own_account? ? true : super
end

def changes_visible? act
  act.relevant_actions_for(act.card).each do |action|
    return true if action.card.ok? :read
  end
  false
end

def send_change_notice act, followed_set, follow_option
  return unless changes_visible?(act)
  Auth.as(left.id) do
    Card[:follower_notification_email].deliver(
      context:       act.card,
      to:            email,
      follower:      left.name,
      followed_set:  followed_set,
      follow_option: follow_option
    )
  end
end

format :email do
  view :mail do |args|
    args[:to] ||= card.email
    super args
  end
end
