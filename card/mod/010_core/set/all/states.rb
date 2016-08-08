def new_card?
  new_record? || # not yet in db (from ActiveRecord)
    !!@from_trash    # in process of restoration from trash, not yet "re-created"
end
alias new? new_card?

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
