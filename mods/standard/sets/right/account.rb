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


event :set_default_salt, :on=>:create, :before=>:process_subcards do
  salt = Digest::SHA1.hexdigest "--#{Time.now.to_s}--"
  Wagn::Env[:salt] = salt # HACK!!! need viable mechanism to get this to password
  subcards["+#{Card[:salt].name}"] ||= {:content => salt }
end

event :set_default_status, :on=>:create, :before=>:process_subcards do
  subcards["+#{Card[:status].name}"] = { :content => ( Account.signed_in? ? 'active' : 'pending' ) }
end

event :generate_token, :on=>:create, :before=>:process_subcards do
  subcards["+#{Card[:token].name}"] = {:content => Digest::SHA1.hexdigest( "--#{Time.now.to_s}--#{rand 10}--" ) }
end

=begin
event :notify_accounted, :on=>:create, :after=>:extend do
  if active? #FIXME - should be newly active!
    email_args = Wagn::Env.params[:email] || {}
    email_args[:message] ||= Card.setting('*signup+*message') || "Thanks for signing up to #{Card.setting('*title')}!"
    email_args[:subject] ||= Card.setting('*signup+*subject') || "Click below to activate your account on #{Card.setting('*title')}!"
    confirmation_email( email_args ).deliver
  end
end
=end

event :send_new_account_confirmation_email, :on=>:create, :after=>:extend do
  if self.email.present?
    Mailer.confirmation_email( self ).deliver
  end
end

def ok_to_read
  is_own_account? ? true : super
end
