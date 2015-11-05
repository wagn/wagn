module Card::ActiveRecordHelper
  def create_card args
    resolve_name_conflict args
    Card.create! args
  end

  def create_card! args
    create_card args.merge(rename_if_conflict: :other)
  end

  def update_card name, args
    resolve_name_conflict args
    Card[name].update_attributes! args
  end

  def update_card! args
    update_card args.merge(rename_if_conflict: :other)
  end

  def create_or_update name_or_args, args=nil
    name = args ? name_or_args : name_or_args[:name]
    args ||= name_or_args
    if Card[name]
      update_card name, args
    else
      create_card args.merge(:name=>name)
    end
  end

  def create_or_update! name_or_args, args=nil
    if args
      args[:rename_if_conflict] = :other
    else
      name_or_args[:rename_if_conflict] = :other
    end
    create_or_update name_or_args, args
  end

  def resolve_name_conflict args
    if (rename = args.delete :rename_if_conflict)
      args[:name] = Card.uniquify_name args[:name], rename == :other
    end
  end
end