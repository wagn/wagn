class Card
  class Act
    class ActRenderer
      class RelativeActRenderer < ActRenderer
        def title
          "<span class=\"nr\">##{@args[:act_seq]}</span>" +
            accordion_expand_link(@act.actor.name) +
            " " +
            wrap_with(:small, edited_ago)
        end

        def subtitle
          return "" unless @act.card_id != @format.card.id
          wrap_with :small, "act on #{absolute_title}"
        end

        def act_links
          return unless (content = rollback_or_edit_link)
          wrap_with :small, content
        end

        def rollback_or_edit_link
          if @act.draft?
            autosaved_draft_link text: "continue editing",
                                 class: "collapse #{collapse_id}"
          elsif !current_act?
            rollback_link
          end
        end

        def current_act?
          @act.id == @format.card.last_act.id
        end

        def actions
          @actions ||= @act.actions_affecting(@card)
        end
      end
    end
  end
end
