#require_dependency File.expand_path("../../action/action_renderer", __FILE__)

class Card
  class Act
    class ActRenderer
      def initialize format, act, args
        @format = format
        @act = act
        @args = args
        @card = @format.card
        @context = @args[:act_context]
      end

      def method_missing method_name, *args, &block
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
        act_accordion
      end

      def header
        Format::HtmlFormat::Bootstrap::Layout.render self, {} do
          row 10, 2 do
            col do
              html title
              tag(:span, "text-muted") { summary }
            end
            col act_links, class: "text-right"
          end
          row 12 do
            col subtitle
          end
        end
      end

      def absolute_title
        accordion_expand_link(@act.card.name)
      end

      def details
        approved_actions[0..20].map do |action|
          Action::ActionRenderer.new(@format, action, action_header?,
                                     :summary).render
        end.join
      end

      def summary
        [:create, :update, :delete, :draft].map do |type|
          next unless count_types[type] > 0
          "#{@format.action_icon type} #{count_types[type]}"
        end.compact.join " | "
      end

      def act_links
        [
          link_to_history,
          (link_to_act_card unless @act.card.trash)
        ].compact.join " "
      end

      def link_to_act_card
        link_to_card @act.card, glyphicon("new-window")
      end

      def link_to_history
        link_to_card @act.card, glyphicon("time"), path: { view: :history,
                                                           look_in_trash: true }
      end

      def approved_actions
        @approved_actions ||= actions.select { |a| a.card && a.card.ok?(:read) }
        # FIXME: should not need to test for presence of card here.
      end

      def action_header?
        true
        # @action_header ||= approved_actions.size != 1 ||
        #                   approved_actions[0].card_id != @format.card.id
      end

      def count_types
        @count_types ||=
          approved_actions.each_with_object(
            Hash.new { |h, k| h[k] = 0 }
          ) do |action, type_cnt|
            type_cnt[action.action_type] += 1
          end
      end

      def edited_ago
        "#{time_ago_in_words(@act.acted_at)} ago"
      end

      def collapse_id
        "act-id-#{@act.id}"
      end

      def accordion_expand_link text
        <<-HTML
          <a>
            #{text}
          </a>
        HTML
      end

      # TODO: change accordion API in bootstrap/helper.rb so that it can be used
      #   here. The problem is that here we have extra links in the title
      #   that are not supposed to expand the accordion
      def act_accordion
        context = @act.main_action.draft ? :warning : :default
        <<-HTML
        <div class="panel panel-#{context}">
          #{act_accordion_panel}
        </div>
        HTML
      end

      def accordion_expand_options
        {
          "data-toggle" => "collapse",
          "data-parent" => "#accordion-#{collapse_id}",
          "data-target" => ".#{collapse_id}",
          "aria-expanded" => true,
          "aria-controls" => collapse_id
        }
      end

      def act_panel_options
        { class: "panel-heading", role: "tab", id: "heading-#{collapse_id}" }
      end

      def act_accordion_panel
        act_accordion_heading + act_accordion_body
      end

      def act_accordion_heading
        wrap_with :div, act_panel_options.merge(accordion_expand_options) do
          wrap_with :h4, header, class: "panel-title"
        end
      end

      def act_accordion_body
        wrap_with :div, id: collapse_id,
                        class: "panel-collapse collapse #{collapse_id}" do
          wrap_with :div, details, class: "panel-body"
        end
      end

      def rollback_link
        return unless card.ok? :update
        return unless (prior = previous_action)
        wrap_with :div, class: "act-link collapse #{collapse_id}" do
          link_to "Save as current",
                  class: "slotter", remote: true,
                  method: :post,    rel: "nofollow",
                  "data-slot-selector" => ".card-slot.history-view",
                  path: { action: :update, action_ids: prior,
                          view: :open,     look_in_trash: true }
        end
      end

      def previous_action
        # TODO: optimize
        actions.select { |action| action.card.last_action_id != action.id }
      end

      def show_or_hide_changes_link
        wrap_with :div, class: "act-link" do
          @format.link_to_view(
            :act, "#{@args[:hide_diff] ? 'Show' : 'Hide'} changes",
            class: "slotter",
            path: { act_id:      @args[:act].id,      act_seq: @args[:act_seq],
                    hide_diff:  !@args[:hide_diff],   action_view: :expanded,
                    act_context: @args[:act_context], look_in_trash: true }
          )
        end
      end
    end
  end
end
