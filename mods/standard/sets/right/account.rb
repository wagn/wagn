# -*- encoding : utf-8 -*-

include Card::Set::All::Permissions::Accounts

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
    _final_edit args
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
  Wagn::Env[:salt] = salt # HACK!!! need viable mechanism to get this to password
  subcards["+#{Card[:salt].name}"] ||= {:content => salt }
end

event :set_default_status, :on=>:create, :before=>:process_subcards do
  default_status = ( Account.signed_in? || Account.needs_setup? ? 'active' : 'pending' )
  subcards["+#{Card[:status].name}"] = { :content => default_status }
end

event :generate_confirmation_token, :on=>:create, :before=>:process_subcards do
  subcards["+#{Card[:token].name}"] = {:content => generate_token }
end

event :reset_password, :on=>:update, :before=>:approve do
  if token = Wagn::Env.params[:reset_token]    
    if left_id == Account.authenticate_by_token(token)
      Account.signin left_id
      Wagn::Env.params[:success] = { :id=>left.name, :view=>:related,
        :related=>{:name=>"+#{Card[:account].name}", :view=>'edit'}
      }
      abort :success
    else
      abort :failure
      # handle bad token
    end
  end
end

event :send_new_account_confirmation_email, :on=>:create, :after=>:extend do
  if self.email.present?
    Mailer.confirmation_email( self ).deliver
  end
end

def ok_to_read
  is_own_account? ? true : super
end
