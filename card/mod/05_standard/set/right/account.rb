
include All::Permissions::Accounts

card_accessor :email
card_accessor :password
card_accessor :salt
card_accessor :status
card_accessor :token

def active?   ; status=='active'  end
def blocked?  ; status=='blocked' end
def built_in? ; status=='system'  end
def pending?  ; status=='pending' end


def authenticate_by_token val
  tcard = token_card                               or return :token_not_found
  token == val                                     or return :incorrect_token
  tcard.updated_at > Card.config.token_expiry.ago  or return :token_expired  # > means "after"
  left and left.accountable?                       or return :illegal_account  #(overkill?)
  Auth.as_bot { tcard.delete! }
  left.id
end


format do
  view :verify_url do |args|
    card_url "update/#{card.cardname.left_name.url_key}?token=#{card.token}"
  end

  view :verify_days do |args|
    ( Card.config.token_expiry / 1.day ).to_s
  end

  view :reset_password_url do |args|
    card_url "update/#{card.cardname.url_key}?reset_token=#{card.token_card.refresh(true).content}"
  end

  view :reset_password_days do |args|
    ( Card.config.token_expiry / 1.day ).to_s
  end
end


format :html do

  view :raw do |args|
    content = []
    content << "{{+#{Card[:email   ].name}|titled;title:email}}"    unless args[:no_email]
    content << "{{+#{Card[:password].name}|titled;title:password}}" unless args[:no_password]
    content * ' '
  end

  view :edit do |args|
    args[:structure] = true
    super args
  end
end


event :validate_accountability, on: :create, before: :approve do
  unless left and left.accountable?
    errors.add :content, "not allowed on this card"
  end
end

event :require_email, on: :create, after: :approve do
  unless subfield(:email)
    errors.add :email, 'required'
  end
end


event :set_default_salt, on: :create, before: :process_subcards do
  salt = Digest::SHA1.hexdigest "--#{Time.now.to_s}--"
  Env[:salt] = salt # HACK!!! need viable mechanism to get this to password
  add_subfield :salt, content: salt
end

event :set_default_status, on: :create, before: :process_subcards do
  default_status = ( Auth.needs_setup? ? 'active' : 'pending' )
  add_subfield :status, content: default_status
end

def confirm_ok?
  Card.new( type_id: Card.default_accounted_type_id ).ok? :create
end

event :generate_confirmation_token, :on=>:create, :before=>:process_subcards, :when=>proc{ |c| c.confirm_ok? } do
  add_subfield :token, content: generate_token
end

event :reset_password, on: :update, before: :approve, when: proc{ |c| c.has_reset_token? } do
  case ( result = authenticate_by_token @env_token )
  when Integer
    Auth.signin result
    success << edit_password_success_args
    abort :success
  when :token_expired
    send_reset_password_token
    success << {
      id: '_self',
      view: 'message',
      message: "Sorry, this token has expired. Please check your email for a new password reset link."
    }
    abort :success
  else
    abort :failure, "error resetting password: #{result}" # bad token or account
  end
end

def edit_password_success_args
  {
    id: left.name,
    view: :related,
    related: { name: "+#{Card[:account].name}", view: 'edit' }
  }
end

def has_reset_token?
  @env_token = Env.params[:reset_token]
end

event :reset_token do
  Auth.as_bot do
    token_card.update_attributes! content: generate_token
  end
end


event :send_welcome_email do
  if ((welcome = Card['welcome email']) && welcome.type_code == :email_template)
    welcome.deliver(context: left, to: self.email)
  end
end

event :send_account_verification_email, on: :create, after: :extend, when: proc{ |c| c.token.present? } do
  Card[:verification_email].deliver( context: self, to: self.email )
end

event :send_reset_password_token do
  Auth.as_bot do
    token_card.update_attributes! content: generate_token
  end
  Card[:password_reset_email].deliver( context: self, to: self.email )
end

def ok_to_read
  is_own_account? ? true : super
end


def changes_visible? act
  act.relevant_actions_for(act.card).each do |action|
    return true if action.card.ok? :read
  end
  return false
end

def send_change_notice act, followed_set, follow_option
  if changes_visible?(act)
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
end


format :email do
  view :mail do |args|
    args[:to] ||= card.email
    super args
  end
end

