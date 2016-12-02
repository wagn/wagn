class Card
  module Model
    # API to create and update cards.
    # It is intended as a helper for "external" scripts
    # (seeding, testing, migrating, etc) and not for internal application code.
    # The general pattern is:
    # All methods use the ActiveRecord !-methods that throw exceptions if
    # somethings fails.
    # All !-methods in this module rename existing cards
    # to resolve name conflicts)
    module SaveHelper
      def create_card name_or_args, content_or_args=nil
        args = standardize_args name_or_args, content_or_args
        resolve_name_conflict args
        Card.create! args
      end

      def update_card name, content_or_args
        args = standardize_update_args name, content_or_args
        resolve_name_conflict args
        Card[name].update_attributes! args
      end

      def create_or_update_card name_or_args, content_or_args=nil
        name = name_from_args name_or_args

        if Card[name]
          args = standardize_update_args name_or_args, content_or_args
          update_card(name, args)
        else
          args = standardize_args name_or_args, content_or_args
          create_card(args)
        end
      end

      def delete_card name
        return unless (card = Card[name])
        card.delete!
      end

      def delete_code_card name
        update name, codename: nil
        delete name
      end

      # create if card doesn't exist
      # updates existing card only if given attributes are different except the
      # name
      # @example if a card with name "under_score" exists
      #   ensure_card "Under Score"                 # => no change
      #   ensure_card "Under Score", type: :pointer # => changes the type to pointer
      #                                             #    but not the name
      def ensure_card name_or_args, content_or_args=nil
        args = standardize_args name_or_args, content_or_args
        name = args.delete(:name)
        if (card = Card[name])
          ensure_attributes card, args
          card
        else
          Card.create! args.merge(name: name)
        end
      end

      # create if card doesn't exist
      # updates existing card only if given attributes are different including
      # the name
      # For example if a card with name "under_score" exists
      # then `ensure_card "Under Score"` renames it to "Under Score"
      def ensure_card! name_or_args, content_or_args=nil
        args = standardize_args name_or_args, content_or_args
        if (card = Card[args[:name]])
          ensure_attributes card, args
        else
          Card.create! args
        end
      end

      # if card with same name exists move it out of the way
      def create_card! name_or_args, content_or_args=nil
        args = standardize_args name_or_args, content_or_args
        create_card args.reverse_merge(rename_if_conflict: :old)
      end

      def update_card! name, content_or_args
        args = standardize_update_args name, content_or_args
        update_card name, args.reverse_merge(rename_if_conflict: :new)
      end

      def create_or_update_card! name_or_args, content_or_args=nil
        args = standardize_args name_or_args, content_or_args
        create_or_update args.reverse_merge(rename_if_conflict: :new)
      end

      # @return args
      def standardize_args name_or_args, content_or_args
        if name_or_args.is_a?(Hash)
          name_or_args
        else
          add_name name_or_args, content_or_args
        end
      end

      def standardize_update_args name_or_args, content_or_args
        return name_or_args if name_or_args.is_a?(Hash)
        if content_or_args.is_a?(String)
          { content: content_or_args }
        else
          content_or_args
        end
      end

      def name_from_args name_or_args
        name_or_args.is_a?(Hash) ? name_or_args[:name] : name_or_args
      end

      def add_name name, content_or_args
        if content_or_args.is_a?(String)
          { content: content_or_args, name: name }
        else
          content_or_args.reverse_merge name: name
        end
      end

      def resolve_name_conflict args
        rename = args.delete :rename_if_conflict
        return unless args[:name] && rename
        args[:name] = Card.uniquify_name args[:name], rename
      end

      def ensure_attributes card, args
        update_args = args.select { |key, value| card.send(key) != value }
        return if update_args.empty?
        card.update_attributes! update_args
      end

      def add_style name, opts={}
        name.sub!(/^style\:?\s?/, '') # in case name is given with prefix
        # remove it so that we don't double it

        add_coderule_item name, "style",
                          opts[:type_id] || Card::ScssID,
                          opts[:to] || "*all+*style"
      end

      def add_script name, opts={}
        name.sub!(/^script\:?\s?/, '') # in case name is given with prefix
        # remove it so that we don't double it

        add_coderule_item name, "script",
                          opts[:type_id] || Card::CoffeeScriptID,
                          opts[:to] || "*all+*script"
      end


      def add_coderule_item name, prefix, type_id, to
        codename = "#{prefix}_#{name.tr(' ', '_').underscore}"
        name = "#{prefix}: #{name}"

        ensure_card name, type_id: type_id,
                    codename: codename
        Card[to].add_item! name
      end

      alias_method :create, :create_card
      alias_method :update, :update_card
      alias_method :create_or_update, :create_or_update_card
      alias_method :create!, :create_card!
      alias_method :update!, :update_card!
      alias_method :create_or_update!, :create_or_update_card!
      alias_method :ensure, :ensure_card
      alias_method :ensure!, :ensure_card!
      alias_method :delete, :delete_card
    end
  end
end
