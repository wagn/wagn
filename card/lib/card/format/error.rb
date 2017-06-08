class Card
  class Format
    module Error
      def rescue_view e, view
        raise e if Rails.env =~ /^cucumber|test$/
        error_view = Card::Error.exception_view @card, e
        # TODO: consider rendering dynamic error view here.
        rendering_error e, view
      end

      def debug_error e
        debug = Card[:debugger]
        raise e if debug && debug.content == "on"
      end

      def error_cardname
        card && card.name.present? ? card.name : "unknown card"
      end

      def rendering_error _exception, view
        "Error rendering: #{error_cardname} (#{view} view)"
      end
    end
  end
end
