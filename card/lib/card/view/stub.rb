class Card
  class View
    # A "stub" is a placeholder for a card view. It can only be used in
    # situations where the card identifier, known options, and nest mode
    # comprise all the info needed to reproduce the view as intended
    module Stub
      def stub
        "<card-view>#{stub_json}</card-view>"
      end

      def stub_json
        JSON.generate stub_hash
      end

      def stub_hash
        {
          cast: card.cast,
          options: normalized_options,
          mode: format.mode
        }
      end

      def validate_stub
        return if foreign_normalized_options.empty?
        raise "INVALID STUB: #{card.name}/#{ok_view}" \
              " has foreign options: #{foreign_normalized_options}"
      end
    end
  end
end
