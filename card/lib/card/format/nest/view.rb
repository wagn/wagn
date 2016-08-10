class Card
  class Format
    module Nest
      # Renders views for a nests
      module View
        NEST_MODES = { new: :edit,
                       closed_content: :closed,
                       setup: :edit,
                       edit: :edit, closed: :closed, layout: :layout,
                       normal: :normal, template: :template }.freeze

        def nest_render view, opts
          optional_render nest_view(view), opts
        end

        def with_nest_mode mode
          if (switch_mode = NEST_MODES[mode]) && @mode != switch_mode
            old_mode = @mode
            @mode = switch_mode
            @nest_defaults = nil
          end
          result = yield
          if old_mode
            @nest_defaults = nil
            @mode = old_mode
          end
          result
        end

        private

        def nest_view view
          # This was refactored based on the assumption that the subformat
          # has always the same @mode as its parent format
          # The nest view used to be based on the mode of the parent format
          case @mode
          when :edit then view_in_edit_mode(view)
          when :template then :template_rule
          when :closed then view_in_closed_mode(view)
          else view
          end
        end

        # Returns the view that the card should use
        # if nested in edit mode
        def view_in_edit_mode homeview
          not_in_form =
            Card::Format.perms[homeview] == :none || # view configured not to keep in form
            card.structure || # not yet nesting structures
            card.key.blank? # eg {{_self|type}} on new cards

          not_in_form ? :blank : :edit_in_form
        end

        # Return the view that the card should use
        # if nested in closed mode
        def view_in_closed_mode homeview
          approved_view = Card::Format.closed[homeview]
          if approved_view == true
            homeview
          elsif Card::Format.error_code[homeview]
            homeview
          elsif approved_view
            approved_view
          elsif !card.known?
            :closed_missing
          else
            :closed_content
          end
        end
      end
    end
  end
end
