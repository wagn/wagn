class Card
  class Format
    module Error
      def rescue_view e, view
        raise e if Rails.env =~ /^cucumber|test$/
        Card::Error.current = e
        card.notable_exception_raised
        rendering_error e, view
      end

      def debug_error e, view
        Rails.logger.info "#{rendering_error e, view}:\n" \
                          "#{e.class} : #{e.message}"
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
