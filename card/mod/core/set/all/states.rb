def state
  case
  when !known?     then :unknown
  when !ok?(:read) then :unknown # anti-fishing
  when real?       then :real
  when virtual?    then :virtual
  else :wtf
  end
end

def new_card?
  new_record? ||       # not yet in db (from ActiveRecord)
    !@from_trash.nil?  # in process of restoration from trash
end
alias_method :new?, :new_card?

def known?
  real? || virtual?
end

def real?
  !new_card?
end

def unknown?
  !known?
end

def pristine?
  # has not been edited directly by human users.  bleep blorp.
  new_card? || !actions.joins(:act).where(
    "card_acts.actor_id != ?", Card::WagnBotID
  ).exists?
end
