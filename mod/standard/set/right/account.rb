
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

format :html do

  view :raw do |args|
    %{
      {{+#{Card[:email   ].name}|titled;title:email}}
      {{+#{Card[:password].name}|titled;title:password}}
    }
  end

  view :edit do |args|
    args[:structure] = true
    super args
  end
end


event :validate_accountability, :on=>:create, :before=>:approve do
  unless left and left.accountable?
    errors.add :content, "not allowed on this card"
  end
end

event :require_email, :on=>:create, :after=>:approve do
  unless subcards["+#{Card[:email].name}"] 
    errors.add :email, 'required'
  end
end


event :set_default_salt, :on=>:create, :before=>:process_subcards do
  salt = Digest::SHA1.hexdigest "--#{Time.now.to_s}--"
  Env[:salt] = salt # HACK!!! need viable mechanism to get this to password
  subcards["+#{Card[:salt].name}"] ||= {:content => salt }
end

event :set_default_status, :on=>:create, :before=>:process_subcards do
  default_status = ( Auth.signed_in? || Auth.needs_setup? ? 'active' : 'pending' )
  subcards["+#{Card[:status].name}"] = { :content => default_status }
end

def confirm_ok?
  Card.new( :type_id=>Card.default_accounted_type_id ).ok? :create
end

event :generate_confirmation_token, :on=>:create, :before=>:process_subcards, :when=>proc{ |c| c.confirm_ok? } do
  subcards["+#{Card[:token].name}"] = {:content => generate_token }
end

event :reset_password, :on=>:update, :before=>:approve, :when=>proc{ |c| c.has_reset_token? } do
  result = Auth.authenticate_by_token @env_token
  case result
  when Integer
    Auth.signin result
    Env.params[:success] = { :id=>left.name, :view=>:related,
      :related=>{:name=>"+#{Card[:account].name}", :view=>'edit'}
    }
    abort :success
  when :token_expired
    send_reset_password_token
    Env.params[:success] = {
      :id => '_self',
      :view => 'message',
      :message => "Sorry, this token has expired. Please check your email for a new password reset link."
    }
    abort :success
  else
    abort :failure, "error resetting password: #{result}" # bad token or account
  end
end

def has_reset_token?
  @env_token = Env.params[:reset_token]
end

event :reset_token do
  Auth.as_bot do
    token_card.update_attributes! :content => generate_token
  end
end
  

event :send_account_confirmation_email, :on=>:create, :after=>:extend do
  if self.email.present?
    Mailer.confirmation_email( self ).deliver
  end
end

event :send_reset_password_token do
  reset_token
  Mailer.password_reset(self).deliver
end

def ok_to_read
  is_own_account? ? true : super
end
