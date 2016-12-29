class Card
  class Action
    class ActionRenderer
      attr_reader :action, :header
      def initialize format, action, header=true, action_view=:summary, hide_diff=false
        @format = format
        @action = action
        @header = header
        @action_view = action_view
        @hide_diff = hide_diff
      end

      include ::Bootstrapper
      def method_missing(method_name, *args, &block)
        if block_given?
          @format.send(method_name, *args, &block)
        else
          @format.send(method_name, *args)
        end
      end

      def respond_to_missing? method_name, _include_private=false
        @format.respond_to? method_name
      end

      def render
        bs_layout container: true, fluid: true do
          row do
            html <<-HTML
              <ul class="action-list">
                <li class="glyphicon-bullet #{action.action_type}">
                  #{action_panel}
                </li>
              </ul>
            HTML
          end
        end
      end

      def action_panel
        bs_panel do
          if header
            heading do
              div type_diff, class: "pull-right"
              div name_diff
            end
          end
          body do
            content_diff
          end
        end
      end

      def name_diff
        if @action.card == @format.card
          name_changes
        else
          link_to_view(
            :related, name_changes,
            path: { related: { view: "history", name: @action.card.name } },
            remote: true,
            class: "slotter",
            #"data-slot-selector" => ".card-slot.history-view"
          )
        end
      end

      def content_diff
        return @action.raw_view if @action.action_type == :delete
        @format.subformat(@action.card)._render_action_summary action: @action
      end

      def type_diff
        return "" unless @action.new_type?
        @hide_diff ? @action.value(:cardtype) : @action.cardtype_diff
      end

      def name_changes
        return old_name unless @action.new_name?
        @hide_diff ? new_name : Card::Content::Diff.complete(old_name, new_name)
      end

      def old_name
        (name = @action.previous_value :name) && showname(name).to_s
      end

      def new_name
        showname(@action.value(:name)).to_s
      end
    end
  end
end
