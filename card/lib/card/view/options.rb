class Card
  class View

    module Options
      def load_options
        options
        process_visibility_options
      end

      def normalized_options
        @normalized_options ||= begin
          options = options_to_hash @raw_options.clone
          options.deep_symbolize_keys!
          options[:view] = original_view
  #          options[:main] = @format.main?
          options #.reject { |_k, v| v.blank? }
        end
      end


    end

  end
end
