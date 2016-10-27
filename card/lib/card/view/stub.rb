class Card
  class View
    module Stub
      def validate_stub
        return if foreign_options.empty?
        raise "INVALID STUB: #{@card.name}/#{ok_view}" \
              " has foreign options: #{foreign_options}"
      end

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
        stub_options = options.merge view: requested_view
        stub_visibility_options stub_options
        stub_options
      end

      def stub_visibility_options stub_options
        [:hide, :show].each do |setting|
          stub_options[setting] = viz_hash.keys.select do |k|
            viz_hash[k] == setting
          end.sort.join ","
        end
      end
    end
  end
end
