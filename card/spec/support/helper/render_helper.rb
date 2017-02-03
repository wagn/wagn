class Card
  module SpecHelper
    module RenderHelper
      def render_editor type
        card = Card.create(name: "my favority #{type} + #{rand(4)}", type: type)
        card.format.render(:edit)
      end

      def render_content content, format_args={}
        render_content_with_args content, format_args
      end

      def render_content_with_args content, format_args={}, view_args={}
        @card ||= Card.new name: "Tempo Rary 2"
        @card.content = content
        @card.format(format_args)._render :core, view_args
      end

      def render_card view, card_args={}, format_args={}
        render_card_with_args view, card_args, format_args
      end

      alias_method :render_view, :render_card

      def render_card_with_args view, card_args={}, format_args={}, view_args={}
        card = begin
          if card_args[:name]
            Card.fetch card_args[:name], new: card_args
          else
            Card.new card_args.merge(name: "Tempo Rary")
          end
        end
        card.format(format_args)._render(view, view_args)
      end
    end
  end
end
