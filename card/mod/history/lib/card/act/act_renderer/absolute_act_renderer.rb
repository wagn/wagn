class Card
  class Act
    class ActRenderer
      class AbsoluteActRenderer < ActRenderer
        def title
          absolute_title
        end

        def subtitle
          wrap_with :small do
            [
              @format.link_to_card(@act.actor),
              edited_ago
            ]
          end
        end

        def actions
          @act.actions
        end
      end
    end
  end
end
