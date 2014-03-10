# -*- encoding : utf-8 -*-

card_accessor :session
card_accessor :token

card_accessor :email
card_accessor :password
card_accessor :salt
card_accessor :status


def active?   ; status=='active'  end
def blocked?  ; status=='blocked' end
def built_in? ; status=='system'  end
def pending?  ; status=='pending' end

# blocked methods for legacy boolean status
def blocked= block
  if block == true
    self.status = 'blocked'
  elsif !built_in?
    self.status = 'active'
  end
end


def confirmation_email args
    args.merge! :to => self.email
    Mailer.confirmation_email left, args
end