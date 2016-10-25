class Card
  class Format
    module Permission
      def ok_view view, skip_permissions=false
        return :too_deep if subformats_nested_too_deeply?
        approved_view = check_view view, skip_permissions
        handle_view_denial view, approved_view
        assign_view_error_status approved_view

        approved_view
      end

      def handle_view_denial view, approved_view
        return if approved_view == view
        @denied_view = view
      end

      def assign_view_error_status view
        return unless focal?
        return unless (error_code = Card::Format.error_code[view])
        root.error_status = error_code
      end

      def check_view view, skip_permissions
        case
        when skip_permissions                 then view
        when view_always_permitted?(view)     then view
        when unknown_disqualifies_view?(view) then view_for_unknown view
        else permitted_view view  # run explicit permission checks
        end
      end

      def unknown_disqualifies_view? view
        # view can't handle unknown cards (and card is unknown)
        return if tagged view, :unknown_ok
        card.unknown?
      end

      def subformats_nested_too_deeply?
        # prevent recursion
        @depth >= Card.config.max_depth
      end

      def view_always_permitted? view
        Card::Format.perms[view] == :none
      end

      def permitted_view view
        if (@denied_task = task_denied_for_view view)
          Card::Format.denial[view] || :denial
        else
          view
        end
      end

      def task_denied_for_view view
        perms_required = Card::Format.perms[view] || :read
        if perms_required.is_a? Proc
          :read unless perms_required.call(self)  # read isn't quite right
        else
          [perms_required].flatten.find { |task| !ok? task }
        end
      end

      def view_for_unknown _view
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
