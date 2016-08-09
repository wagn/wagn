class Card
  module ActiveRecordHelper
    def create_card args
      resolve_name_conflict args
      Card.create! args
    end

    # if card with same name exists move it out of the way
    def create_card! args
      create_card args.reverse_merge(rename_if_conflict: :old)
    end

    def update_card name, args
      resolve_name_conflict args
      Card[name].update_attributes! args
    end

    def update_card! args
      update_card args.reverse_merge(rename_if_conflict: :new)
    end

    def create_or_update name_or_args, args={}
      if name_or_args.is_a?(Hash)
        name = name_or_args.delete :name
        args = name_or_args
      else
        name = name_or_args
      end
      if Card[name]
        update_card name, args
      else
        create_card args.merge(name: name)
      end
    end

    def create_or_update! name_or_args, args=nil
      if name_or_args.is_a?(Hash)
        name = name_or_args.delete(:name)
        args = name_or_args
      else
        name = name_or_args
        args ||= {}
      end
      create_or_update name, args.reverse_merge(rename_if_conflict: :new)
    end

    def resolve_name_conflict args
      rename = args.delete :rename_if_conflict
      return unless rename
      args[:name] = Card.uniquify_name args[:name], rename
    end

    # create if it doesn't exist
    def ensure_card args
      return if Card[args[:name]]
      Card.create! args
    end
  end
end
