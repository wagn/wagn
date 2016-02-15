class Card
  class Format
    module Permission
      def ok_view view, args={}
        return view if args.delete :skip_permissions
        approved_view = approved_view view, args
        args[:denied_view] = view if approved_view != view
        if focal? && (error_code = Card::Format.error_code[approved_view])
          root.error_status = error_code
        end
        approved_view
      end

      def approved_view view, args={}
        case
        when @depth >= Card.config.max_depth
          # prevent recursion. @depth tracks subformats
          :too_deep
        when Card::Format.perms[view] == :none
          # permission skipping specified in view definition
          view
        when args.delete(:skip_permissions)
          # permission skipping specified in args
          view
        when !card.known? && !tagged(view, :unknown_ok)
          # handle unknown cards (where view not exempt)
          view_for_unknown view, args
        else
          # run explicit permission checks
          permitted_view view, args
        end
      end

      def permitted_view view, args
        perms_required = Card::Format.perms[view] || :read
        args[:denied_task] =
          if perms_required.is_a? Proc
            :read unless perms_required.call(self)  # read isn't quite right
          else
            [perms_required].flatten.find { |task| !ok? task }
          end

        if args[:denied_task]
          Card::Format.denial[view] || :denial
        else
          view
        end
      end

      def view_for_unknown _view, _args
        # note: overridden in HTML
        focal? ? :not_found : :missing
      end

      def ok? task
        task = :create if task == :update && card.new_card?
        @ok ||= {}
        @ok[task] = card.ok? task if @ok[task].nil?
        @ok[task]
      end
    end
  end
end
