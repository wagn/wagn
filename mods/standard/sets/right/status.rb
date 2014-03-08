# -*- encoding : utf-8 -*-


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

