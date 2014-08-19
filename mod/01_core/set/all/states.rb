def new_card?
  new_record? || !!@from_trash
end

def known?
  real? || virtual?
end

def real?
  !new_card?
end

def pristine?
  # has not been edited directly by human users.  bleep blorp.
  new_card? or !revisions.map(&:creator_id).find { |id| id != Card::WagnBotID }
end
