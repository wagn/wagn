module Card::Constant
  ID_CONST_ALIAS = {
    :anon         => :anonymous,
    :admin        => :administrator
  }

  def const_missing const
    if const.to_s =~ /^([A-Z]\S*)ID$/ and code=$1.underscore.to_sym
      code = ID_CONST_ALIAS[code] || code
      if card_id = Card::Codename[code]
        const_set const, card_id
      else
        raise "Missing codename #{code} (#{const}) #{caller*"\n"}"
      end
    else
      super
    end
  end
end
