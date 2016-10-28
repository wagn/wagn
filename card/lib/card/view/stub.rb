class Card
  class View
    module Stub
      def stub
        "<card-view>#{stub_json}</card-view>"
      end

      def stub_json
        JSON.generate stub_array
      end

      def stub_array
        [@card.cast, stub_options, @format.mode, @format.main?]
      end

      def stub_options
        slot_options.merge view: requested_view
      end

      def validate_stub
        return if foreign_options.empty?
        raise "INVALID STUB: #{@card.name}/#{ok_view}" \
              " has foreign options: #{foreign_options}"
      end
    end
  end
end
