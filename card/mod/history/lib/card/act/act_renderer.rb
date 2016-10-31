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
          row 11, 1 do
            col do
              tag(:h4, "pull-left") { title }
              tag(:span, "pull-left text-muted") { summary }
            end
            # col do
            #   html link_to_card(@act.card, glyphicon("time", "pull-right"), path: {view: :history, look_in_trash: true})
            #   html link_to_card(@act.card, glyphicon("new-window", "pull-right"))
            # end
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
        approved_actions.map do |action|
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

      def links
        ""
      end

      def approved_actions
        @approved_actions ||= actions.select { |a| a.card && a.card.ok?(:read) }
        # FIXME: should not need to test for presence of card here.
      end

      def action_header?
        true
        #@action_header ||= approved_actions.size != 1 ||
        #                   approved_actions[0].card_id != @format.card.id
      end

      def count_types
        @count_types ||=
          actions.each_with_object(Hash.new { |h, k| h[k] = 0 }) do |action, type_cnt|
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
        <<-STRING
          data-toggle="collapse" data-parent="#accordion-#{collapse_id}" \
          data-target=".#{collapse_id}" aria-expanded="true" \
                   aria-controls="#{collapse_id}"
        STRING
      end

      def act_accordion_panel
        <<-HTML
          <div class="panel-heading" #{accordion_expand_options} role="tab" id="heading-#{collapse_id}">
            <h4 class="panel-title">
               #{header}
            </h4>
            #{links}
          </div>
          <div id="#{collapse_id}" class="panel-collapse collapse #{collapse_id}" \
                 role="tabpanel" aria-labelledby="heading-#{collapse_id}">
            <div class="panel-body">
              #{details}
            </div>
          </div>
        HTML
      end

      def rollback_link
        # FIXME -- doesn't this need to specify which action it wants?
        prior =  # FIXME - should be a Card::Action method
          actions.select { |action| action.card.last_action_id != action.id }
        return unless card.ok?(:update) && prior.present?
        link = link_to(
          "Save as current", class: "slotter",
          "data-slot-selector" => ".card-slot.history-view",
          remote: true, method: :post, rel: "nofollow",
          path: { action: :update, action_ids: prior,
                  view: :open, look_in_trash: true }
        )
        %(<div class="act-link collapse #{collapse_id}">#{link}</div>).html_safe
      end

      def show_or_hide_changes_link
        link = @format.link_to_view(
          :act, "#{@args[:hide_diff] ? 'Show' : 'Hide'} changes",
          class: "slotter",
          path: { act_id:      @args[:act].id,      act_seq: @args[:act_seq],
                  hide_diff:  !@args[:hide_diff],   action_view: :expanded,
                  act_context: @args[:act_context], look_in_trash: true }
        )
        %(<div class="act-link">#{link}</div>)
      end
    end
  end
end
