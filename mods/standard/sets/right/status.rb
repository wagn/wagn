# -*- encoding : utf-8 -*-

def permit action, verb=nil
  is_own_account? ? true : super(action, verb)
end

