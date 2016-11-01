class Card
  class View
    module Stub
      def stub
        "<card-view>#{stub_json}</card-view>"
      end

      def stub_json
        JSON.generate stub_hash
      end

      def stub_hash
        {
          cast: @card.cast,
          options: normalized_options,
          mode: @format.mode
        }
      end

      def validate_stub
        return if foreign_normalized_options.empty?
        raise "INVALID STUB: #{@card.name}/#{ok_view}" \
              " has foreign options: #{foreign_normalized_options}"
      end
    end
  end
end
