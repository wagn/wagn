def t key, args={}
  I18n.t key, args.merge(scope: Card::Set.scope(caller))
end

format do
  def t key, args={}
    I18n.t key, args.merge(scope: Card::Set.scope(caller))
  end
end
