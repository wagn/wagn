# -*- encoding : utf-8 -*-


card_accessor :email
card_accessor :password
card_accessor :salt
card_accessor :status
card_accessor :token

#card_accessor :session


def active?   ; status=='active'  end
def blocked?  ; status=='blocked' end
def built_in? ; status=='system'  end
def pending?  ; status=='pending' end

=begin
# blocked methods for legacy boolean status
def blocked= block
  if block == true
    self.status = 'blocked'
  elsif !built_in?
    self.status = 'active'
  end
end
=end

def confirmation_email args
  Mailer.confirmation_email left, args.merge(:to=>email)
end


event :set_default_salt, :on=>:create, :before=>:process_subcards do
  subcards["+#{Card[:salt].name}"] ||= {:content => Digest::SHA1.hexdigest( "--#{Time.now.to_s}--" ) }
end

event :set_default_status, :on=>:create, :before=>:process_subcards do
  subcards["+#{Card[:status].name}"] = { :content => 'pending' }
end

event :generate_token, :on=>:create, :before=>:process_subcards do
  subcards["+#{Card[:token].name}"] = {:content => Digest::SHA1.hexdigest( "--#{Time.now.to_s}--#{rand 10}--" ) }
end

event :notify_accounted, :on=>:create, :after=>:extend do
  if active? #FIXME - should be newly active!
    email_args = Wagn::Env.params[:email] || {}
    email_args[:message] ||= Card.setting('*signup+*message') || "Thanks for signing up to #{Card.setting('*title')}!"
    email_args[:subject] ||= Card.setting('*signup+*subject') || "Click below to activate your account on #{Card.setting('*title')}!"
    confirmation_email( email_args ).deliver
  end
end

def permit action, verb=nil
  is_own_account? ? true : super(action, verb)
end

def ok_to_read
  is_own_account? ? true : super
end